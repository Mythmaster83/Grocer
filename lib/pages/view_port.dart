import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/models/list_item.dart';
import 'package:grocer_app/widgets/list_items/list_item_edit.dart';
import 'package:grocer_app/widgets/list_items/hero_item_tile.dart';
import 'package:grocer_app/widgets/dialogs/shopping_complete_dialog.dart';
import 'package:grocer_app/widgets/dialogs/add_item_dialog.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/widgets/dialogs/voice_input_dialog.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/data/grocery_items.dart';
import 'package:grocer_app/utils/item_category_helper.dart';

class ViewPort extends StatefulWidget {
  const ViewPort({
    required this.title,
    required this.themeColor,
    this.isGrocery = true,
    super.key,
  });

  final String title;
  final Color themeColor;
  final bool isGrocery; // true for grocery lists, false for stock lists

  @override
  State<ViewPort> createState() => _ViewPortState();
}

class _ViewPortState extends State<ViewPort> {
  late PageController _pageController;
  late ScrollController _normalScrollController;
  late ScrollController _editScrollController;
  StreamSubscription<List<ListItem>>? _subscription;
  List<ListItem> _items = [];
  final Map<Id, int> _pendingQuantityChanges = {}; // Track changes by item ID


  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _normalScrollController = ScrollController();
    _editScrollController = ScrollController();
    _loadItems();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pageController.dispose();
    _normalScrollController.dispose();
    _editScrollController.dispose();
    super.dispose();
  }

  void _loadItems() async {
    try {
      final items = await DatabaseService.getListItems(widget.title, !widget.isGrocery);
      debugPrint('[ViewPort] Loaded ${items.length} items for list: "${widget.title}"');
      
      // Filter out invalid items and ensure all have valid data
      final validItems = items.where((item) => 
        item.id > 0 && 
        item.name.isNotEmpty && 
        item.name.trim().isNotEmpty &&
        item.quantity > 0
      ).toList();
      
      debugPrint('[ViewPort] Valid items after filtering: ${validItems.length}');
      for (final item in validItems) {
        debugPrint('[ViewPort] Item: "${item.name}", imagePath: "${item.imagePath ?? "null"}"');
      }
      
      if (mounted) {
        setState(() {
          _items = validItems;
        });
      }

      // Watch for changes
      DatabaseService.watchListItems(widget.title, !widget.isGrocery).then((stream) {
        _subscription?.cancel(); // Cancel existing subscription
        _subscription = stream.listen(
          (items) {
            if (mounted) {
              setState(() {
                // Filter out invalid items and ensure all have valid data
                _items = items.where((item) => 
                  item.id > 0 && 
                  item.name.isNotEmpty && 
                  item.name.trim().isNotEmpty &&
                  item.quantity > 0
                ).toList();
              });
            }
          },
          onError: (error) {
            debugPrint('[ViewPort] Error in stream: $error');
            // Keep existing items on error
          },
        );
      }).catchError((error) {
        debugPrint('[ViewPort] Error setting up stream: $error');
        // Keep existing items on error
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
        });
      }
    }
  }

  void _addItemDialog() {
    showDialog(
      context: context,
      builder: (_) => AddItemDialog(
        listName: widget.title,
        isStockList: !widget.isGrocery,
        onAdd: (String name, int quantity) async {
                    // Capitalize first letter
                    final capitalizedName = name.isNotEmpty 
                        ? name[0].toUpperCase() + name.substring(1)
                        : name;
                    await DatabaseService.addListItem(widget.title, !widget.isGrocery, capitalizedName, quantity);
                    // Add to suggestions if not already there
                    await GroceryItems.addItemIfNew(capitalizedName);
                },
      ),
    );
  }

  Future<void> _handleVoiceInput() async {
    final result = await showDialog<List<ParsedItem>>(
      context: context,
      builder: (context) => VoiceInputDialog(
        isStockList: !widget.isGrocery,
        existingListName: widget.title,
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Merge duplicate items first, then add to list
      await DatabaseService.mergeDuplicateItems(widget.title, !widget.isGrocery, result);
      
      // Add to suggestions if not already there
      for (final item in result) {
        await GroceryItems.addItemIfNew(item.name);
      }
      
      // Reload items to show the new ones
      _loadItems();
    }
  }

  void _savePendingChanges() async {
    for (var entry in _pendingQuantityChanges.entries) {
      final itemId = entry.key;
      final newQuantity = entry.value;
      final item = _items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => ListItem(listName: '', name: '', quantity: 0, id: -1),
      );
      if (item.id > 0) {
        item.quantity = newQuantity;
        await DatabaseService.updateListItem(item);
      }
    }
    _pendingQuantityChanges.clear();
  }

  int _currentPage = 0;
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // When entering edit mode (page 1), clear any stale pending changes
    if (page == 1) {
      _pendingQuantityChanges.clear();
    }
    // When swiping back to normal view (page 0), save changes
    else if (page == 0 && _pendingQuantityChanges.isNotEmpty) {
      _savePendingChanges();
    }
  }

  Widget _buildNormalView() {
    // Group items by category
    final Map<String, List<ListItem>> itemsByCategory = {};
    for (final item in _items) {
      if (item.id < 0 || item.name.isEmpty) continue;
      final category = ItemCategoryHelper.getItemCategory(item.name);
      itemsByCategory.putIfAbsent(category, () => []).add(item);
    }
    
    // Sort categories alphabetically
    final sortedCategories = itemsByCategory.keys.toList()..sort();
    
    // Build list of widgets (category headers + items)
    final List<Widget> categoryWidgets = [];
    int itemIndex = 0;
    
    for (final category in sortedCategories) {
      final categoryItems = itemsByCategory[category]!;
      
      // Add 10px spacing before category
      categoryWidgets.add(const SizedBox(height: 10));
      
      // Category header
      categoryWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Category: $category',
            style: TextStyleHelper.bodyBold(),
          ),
        ),
      );
      
      // 2px divider (light grey)
      categoryWidgets.add(
        Container(
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          color: PreferencesService.isDarkMode.value 
              ? Colors.grey[700] 
              : Colors.grey[300],
        ),
      );
      
      // 10px spacing after divider
      categoryWidgets.add(const SizedBox(height: 10));
      
      // Add items in this category
      for (final item in categoryItems) {
        final currentIndex = itemIndex++;
        categoryWidgets.add(
          HeroItemTile(
              key: ValueKey('item_${item.id}_${widget.title}_$currentIndex'),
              name: item.name,
              bought: item.bought,
              quantity: item.quantity,
              themeColor: widget.themeColor,
              showCheckbox: widget.isGrocery,
              heroTag: 'item_${item.id}_${widget.title}',
              imagePath: item.imagePath,
              onCheckboxChanged: widget.isGrocery ? (value) async {
                if (mounted && currentIndex < _items.length && _items[currentIndex].id == item.id) {
                  item.bought = value ?? false;
                  await DatabaseService.updateListItem(item);
                }
              } : null,
            ),
        );
      }
    }
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _normalScrollController,
            padding: const EdgeInsets.only(top: 6, bottom: 140),
            itemCount: categoryWidgets.length,
            itemBuilder: (context, index) {
              return categoryWidgets[index];
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.all(14),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _addItemDialog,
                  icon: const Icon(Icons.add),
                  label: ValueListenableBuilder<double>(
                    valueListenable: PreferencesService.textSize,
                    builder: (context, textSize, _) => Text(
                      'Add Item',
                      style: TextStyleHelper.body(),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
                if (!widget.isGrocery) const SizedBox(height: 50),
                if (widget.isGrocery) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: ElevatedButton.icon(
                      onPressed: _items.any((item) => item.bought)
                          ? () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => ShoppingCompleteDialog(
                                  items: _items,
                                  listName: widget.title,
                                ),
                              );
                              if (result == true && mounted) {
                                // Reload items after completion
                                _loadItems();
                              }
                            }
                          : null,
                      icon: const Icon(Icons.check_circle),
                      label: ValueListenableBuilder<double>(
                        valueListenable: PreferencesService.textSize,
                        builder: (context, textSize, _) => Text(
                          'Complete Shopping',
                          style: TextStyleHelper.body(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditView() {
    if (_items.isEmpty) {
      return Center(
        child: Text(
          "No items to edit. Tap '+' to add one.",
          style: TextStyleHelper.body(),
        ),
      );
    }
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _editScrollController,
            padding: const EdgeInsets.only(top: 6, bottom: 140),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              // Bounds check to prevent null access during hit testing
              if (index < 0 || index >= _items.length || _items.isEmpty) {
                return const SizedBox.shrink();
              }
              
              final item = _items[index];
              if (item.id < 0 || item.name.isEmpty || item.name.trim().isEmpty) {
                return const SizedBox.shrink();
              }
          
              final baseQuantity = item.quantity;
              final quantity = _pendingQuantityChanges[item.id] ?? baseQuantity;
              
              // Ensure quantity is valid
              final validQuantity = quantity > 0 ? quantity : 1;

              return ListItemEdit(
                key: ValueKey('edit_${item.name}-${item.id}_$index'), // Unique key for each item
                name: item.name.isNotEmpty ? item.name : 'Unknown Item',
                quantity: validQuantity,
                themeColor: widget.themeColor,
                imagePath: item.imagePath ?? '',
                onQuantityChanged: (newQuantity) {
                  if (mounted && index < _items.length && _items[index].id == item.id) {
                    setState(() {
                      if (newQuantity != baseQuantity) {
                        _pendingQuantityChanges[item.id] = newQuantity;
                      } else {
                        _pendingQuantityChanges.remove(item.id);
                      }
                    });
                  }
                },
                onDelete: () {
                  if (!mounted || index >= _items.length || _items[index].id != item.id) {
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (ctx) => ValueListenableBuilder<double>(
                      valueListenable: PreferencesService.textSize,
                      builder: (context, textSize, _) => AlertDialog(
                        title: Text('Confirm Delete', style: TextStyleHelper.h4()),
                        content: Text('Delete ${item.name}?', style: TextStyleHelper.body()),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('Cancel', style: TextStyleHelper.body()),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              if (mounted) {
                                _pendingQuantityChanges.remove(item.id);
                                await DatabaseService.deleteListItem(item.id);
                              }
                            },
                            child: Text('Delete', style: TextStyleHelper.body()),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: ElevatedButton.icon(
              onPressed: _addItemDialog,
              icon: const Icon(Icons.add),
              label: ValueListenableBuilder<double>(
                valueListenable: PreferencesService.textSize,
                builder: (context, textSize, _) => Text(
                  'Add Item',
                  style: TextStyleHelper.body(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) {
        return ValueListenableBuilder<String>(
          valueListenable: PreferencesService.fontFamily,
          builder: (context, fontFamily, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: widget.themeColor,
            foregroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Save any pending changes before going back
                if (_pendingQuantityChanges.isNotEmpty) {
                  _savePendingChanges();
                }
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(_currentPage == 1 ? Icons.check_box : Icons.edit),
                onPressed: () {
                  if (_currentPage == 1) {
                    // Navigate back to normal view (page 0)
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    // Navigate to edit mode (page 1)
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                tooltip: _currentPage == 1 ? 'Done Editing' : 'Edit Mode',
              ),
            ],
          ),
          floatingActionButton: _currentPage == 1
              ? null // Hide mic button in edit mode (page 1)
              : FloatingActionButton(
                  onPressed: _handleVoiceInput,
                  backgroundColor: widget.themeColor,
                  child: const Icon(Icons.mic),
                ),
          body: _items.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "No items yet. Tap '+' to add one.",
                        style: TextStyleHelper.body(),
                      ),
                    ),
                    IconButton(
                      onPressed: _addItemDialog,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    )
                  ],
                )
              : PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    SizedBox.expand(child: _buildNormalView()),
                    SizedBox.expand(child: _buildEditView()),
                  ],
                ),
        );
      },
        );
      },
    );
  }
}
