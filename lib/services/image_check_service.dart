import 'dart:async';
import '../services/database_service.dart';
import '../services/image_service.dart';

class ImageCheckService {
  static Timer? _periodicTimer;
  static bool _isRunning = false;

  /// Start periodic image checks every 15 minutes
  static void startPeriodicChecks() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // Run initial check immediately
    checkAllMissingImages();
    
    // Then run every 15 minutes
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      checkAllMissingImages();
    });
  }

  /// Stop periodic image checks
  static void stopPeriodicChecks() {
    if (!_isRunning) return;
    
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _isRunning = false;
  }

  /// Check all items and lists for missing images and fetch them
  static Future<void> checkAllMissingImages() async {
    try {
      // Check all grocery lists
      final groceryLists = await DatabaseService.getShoppingLists();
      for (final list in groceryLists) {
        if (list.imagePath == null || list.imagePath!.isEmpty || 
            !await ImageService.imageExists(list.imagePath ?? '')) {
          await _fetchListImage(list.name, false);
        }
      }

      // Check all stock lists
      final stockLists = await DatabaseService.getStockLists();
      for (final list in stockLists) {
        if (list.imagePath == null || list.imagePath!.isEmpty || 
            !await ImageService.imageExists(list.imagePath ?? '')) {
          await _fetchListImage(list.name, true);
        }
      }

      // Check all items in all lists
      final allLists = [...groceryLists, ...stockLists];
      
      for (final list in allLists) {
        final items = await DatabaseService.getListItems(list.name, list.isStockList);
        for (final item in items) {
          if (item.imagePath == null || item.imagePath!.isEmpty || 
              !await ImageService.imageExists(item.imagePath ?? '')) {
            await _fetchItemImage(item.name, list.name, list.isStockList);
          }
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Fetch image for a list
  static Future<void> _fetchListImage(String listName, bool isStockList) async {
    try {
      final imagePath = await ImageService.fetchAndSaveImageForList(listName);
      if (imagePath != null) {
        final list = await DatabaseService.getGroceryListByName(listName, isStockList);
        if (list != null) {
          list.imagePath = imagePath;
          await DatabaseService.updateGroceryList(list);
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Fetch image for an item
  static Future<void> _fetchItemImage(String itemName, String listName, bool isStockList) async {
    try {
      final imagePath = await ImageService.fetchAndSaveImageForItem(itemName);
      if (imagePath != null) {
        // Update all items with this name across all lists
        final allLists = await DatabaseService.getShoppingLists();
        for (final list in allLists) {
          final items = await DatabaseService.getListItems(list.name, false);
          for (final item in items) {
            if (item.name == itemName && (item.imagePath == null || item.imagePath!.isEmpty)) {
              item.imagePath = imagePath;
              await DatabaseService.updateListItem(item);
            }
          }
        }
        final stockLists = await DatabaseService.getStockLists();
        for (final list in stockLists) {
          final items = await DatabaseService.getListItems(list.name, true);
          for (final item in items) {
            if (item.name == itemName && (item.imagePath == null || item.imagePath!.isEmpty)) {
              item.imagePath = imagePath;
              await DatabaseService.updateListItem(item);
            }
          }
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Check and fetch image for a specific item (called when item is created)
  static Future<void> checkItemImage(String itemName) async {
    await _fetchItemImage(itemName, '', false);
  }

  /// Check and fetch image for a specific list (called when list is created)
  static Future<void> checkListImage(String listName, bool isStockList) async {
    await _fetchListImage(listName, isStockList);
  }
}

