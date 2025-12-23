import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:grocer_app/models/grocery_item.dart';
import 'package:grocer_app/models/list_item.dart';
import 'package:grocer_app/models/grocery_list.dart';
import 'package:grocer_app/utils/list_name_helper.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/services/image_service.dart';
import 'package:flutter/foundation.dart';

import 'image_check_service.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [GroceryItemSchema, ListItemSchema, GroceryListSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  // Grocery Lists
  static Future<List<GroceryList>> getShoppingLists() async {
    final isar = await instance;
    final lists = await isar.groceryLists
        .filter()
        .isStockListEqualTo(false)
        .findAll();
    // Convert marked names to display names
    for (var list in lists) {
      list.name = ListNameHelper.getDisplayName(list.name);
    }
    return lists;
  }

  static Future<List<GroceryList>> getStockLists() async {
    final isar = await instance;
    final lists = await isar.groceryLists
        .filter()
        .isStockListEqualTo(true)
        .findAll();
    // Convert marked names to display names
    for (var list in lists) {
      list.name = ListNameHelper.getDisplayName(list.name);
    }
    return lists;
  }

  static Future<void> addGroceryList(String name, bool isStockList) async {
    final isar = await instance;
    // Use marked name for internal storage
    final markedName = ListNameHelper.getMarkedName(name, isStockList);
    final list = GroceryList(name: markedName, isStockList: isStockList);
    await isar.writeTxn(() => isar.groceryLists.put(list));
    
    // Fetch image asynchronously if list doesn't have one (don't block list creation)
    if (list.imagePath == null || list.imagePath!.isEmpty) {
      // Use ImageCheckService to ensure proper checking and updating
      ImageCheckService.checkListImage(name, isStockList).catchError((error) {
        // Silently handle errors
      });
    }
  }

  static Future<void> updateGroceryList(GroceryList list) async {
    final isar = await instance;
    // Ensure the name is marked before saving
    if (!list.name.startsWith('GROCERY:') && !list.name.startsWith('STOCK:')) {
      list.name = ListNameHelper.getMarkedName(list.name, list.isStockList);
    }
    await isar.writeTxn(() => isar.groceryLists.put(list));
  }

  static Future<GroceryList?> getGroceryListByName(String name, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(name, isStockList);
    return await isar.groceryLists
        .filter()
        .nameEqualTo(markedName)
        .isStockListEqualTo(isStockList)
        .findFirst();
  }

  /// Check if a list with the given name already exists (for same type)
  static Future<bool> listExists(String name, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(name, isStockList);
    final existing = await isar.groceryLists
        .filter()
        .nameEqualTo(markedName)
        .isStockListEqualTo(isStockList)
        .findFirst();
    return existing != null;
  }

  // Get next upcoming shopping lists grouped by date, sorted chronologically
  static Future<Map<DateTime, List<GroceryList>>> getUpcomingShoppingLists() async {
    final isar = await instance;
    // Get lists directly from database (don't convert names yet)
    final lists = await isar.groceryLists
        .filter()
        .isStockListEqualTo(false)
        .findAll();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<DateTime, List<GroceryList>> grouped = {};

    for (final list in lists) {
      if (list.frequency == null && list.scheduledDate == null) continue;
      
      final nextDate = list.getNextShoppingDate();
      if (nextDate == null) continue;
      
      // Only include future dates or today (exclude past dates)
      final dateKey = DateTime(nextDate.year, nextDate.month, nextDate.day);
      if (dateKey.isBefore(today)) continue;
      
      // Convert to display name for UI
      final displayList = GroceryList(
        id: list.id,
        name: ListNameHelper.getDisplayName(list.name),
        isStockList: list.isStockList,
        imagePath: list.imagePath,
        scheduledDate: list.scheduledDate,
        frequency: list.frequency,
        dayOfWeek: list.dayOfWeek,
        isCompleted: list.isCompleted,
        lastCompletedDate: list.lastCompletedDate,
      );
      
      grouped.putIfAbsent(dateKey, () => []).add(displayList);
    }

    // Sort the map by date keys (chronologically ascending)
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedGrouped = <DateTime, List<GroceryList>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }

    return sortedGrouped;
  }

  static Future<void> deleteGroceryList(String name, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(name, isStockList);
    final list = await isar.groceryLists
        .filter()
        .nameEqualTo(markedName)
        .isStockListEqualTo(isStockList)
        .findFirst();
    if (list != null) {
      await isar.writeTxn(() async {
        // Delete all items in this list (using marked name)
        await isar.listItems
            .filter()
            .listNameEqualTo(markedName)
            .deleteAll();
        // Delete the list
        await isar.groceryLists.delete(list.id);
      });
    }
  }

  // List Items
  static Future<List<ListItem>> getListItems(String listName, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(listName, isStockList);
    return await isar.listItems
        .filter()
        .listNameEqualTo(markedName)
        .findAll();
  }

  static Future<Stream<List<ListItem>>> watchListItems(String listName, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(listName, isStockList);
    return isar.listItems
        .filter()
        .listNameEqualTo(markedName)
        .watch(fireImmediately: true);
  }

  /// Merge or add list item - automatically merges quantities if item exists
  /// Returns true if merged, false if new item created
  static Future<bool> mergeOrAddListItem(String listName, bool isStockList, String name, int quantity) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(listName, isStockList);
    
    // Check if item with same name exists in the list
    final existingItems = await isar.listItems
        .filter()
        .listNameEqualTo(markedName)
        .nameEqualTo(name)
        .findAll();
    
    if (existingItems.isNotEmpty) {
      // Item exists - merge quantities
      final existingItem = existingItems.first;
      existingItem.quantity = existingItem.quantity + quantity;
      await isar.writeTxn(() => isar.listItems.put(existingItem));
      return true; // Merged
    } else {
      // Item doesn't exist - create new
      final item = ListItem(
        listName: markedName,
        name: name,
        quantity: quantity,
        bought: false,
      );
      await isar.writeTxn(() => isar.listItems.put(item));
      
      // Fetch image asynchronously if item doesn't have one (don't block item creation)
      if (item.imagePath == null || item.imagePath!.isEmpty) {
        // Use ImageCheckService to ensure proper checking and updating
        ImageCheckService.checkItemImage(name).catchError((error) {
          // Silently handle errors
        });
      }
      return false; // New item created
    }
  }

  static Future<void> addListItem(String listName, bool isStockList, String name, int quantity) async {
    // Use merge function by default
    await mergeOrAddListItem(listName, isStockList, name, quantity);
  }

  static Future<void> updateListItem(ListItem item) async {
    final isar = await instance;
    await isar.writeTxn(() => isar.listItems.put(item));
  }

  /// Merge duplicate items in a list - combines quantities of items with the same name
  static Future<void> mergeDuplicateItems(String listName, bool isStockList, List<ParsedItem> newItems) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(listName, isStockList);
    
    await isar.writeTxn(() async {
      // Get existing items in the list
      final existingItems = await isar.listItems
          .filter()
          .listNameEqualTo(markedName)
          .findAll();
      
      // Create a map of existing items by name (case-insensitive)
      final existingMap = <String, ListItem>{};
      for (final item in existingItems) {
        final key = item.name.toLowerCase();
        if (existingMap.containsKey(key)) {
          // Merge quantities if item already exists
          existingMap[key]!.quantity += item.quantity;
          // Delete the duplicate
          await isar.listItems.delete(item.id);
        } else {
          existingMap[key] = item;
        }
      }
      
      // Process new items
      for (final parsedItem in newItems) {
        final quantity = parsedItem.quantity == '.' ? 1 : int.tryParse(parsedItem.quantity ?? '1') ?? 1;
        final key = parsedItem.name.toLowerCase();
        
        if (existingMap.containsKey(key)) {
          // Item exists, add to quantity
          existingMap[key]!.quantity += quantity;
          await isar.listItems.put(existingMap[key]!);
        } else {
          // New item, create it
          final newItem = ListItem(
            listName: markedName,
            name: parsedItem.name,
            quantity: quantity,
            bought: false,
          );
          await isar.listItems.put(newItem);
          existingMap[key] = newItem;
          
          // Fetch image asynchronously for new items if they don't have one
          if (newItem.imagePath == null || newItem.imagePath!.isEmpty) {
            // Use ImageCheckService to ensure proper checking and updating
            ImageCheckService.checkItemImage(parsedItem.name).catchError((error) {
              // Silently handle errors
            });
          }
        }
      }
    });
  }

  static Future<void> deleteListItem(Id id) async {
    final isar = await instance;
    await isar.writeTxn(() => isar.listItems.delete(id));
  }

  static Future<void> deleteAllListItems(String listName, bool isStockList) async {
    final isar = await instance;
    final markedName = ListNameHelper.getMarkedName(listName, isStockList);
    await isar.writeTxn(() => isar.listItems
        .filter()
        .listNameEqualTo(markedName)
        .deleteAll());
  }
}

