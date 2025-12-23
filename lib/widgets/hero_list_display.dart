import 'package:flutter/material.dart';
import '../utils/text_style_helper.dart';
import '../services/preferences_service.dart';
import '../services/database_service.dart';
import '../services/icon_mapping_service.dart';
import '../utils/item_category_helper.dart';
import '../services/home_refresh_service.dart';
import '../models/list_item.dart';
import '../models/grocery_list.dart' show GroceryList, ScheduleFrequency;
import 'dialogs/scheduling_dialog.dart';
import '../services/notification_service.dart';
import '../services/image_check_service.dart';
import '../data/funcs.dart';
import '../data/item_units.dart';
import 'image_with_info_icon.dart';

class HeroListDisplay extends StatefulWidget {
  final String title;
  final String imagePath; // Kept for compatibility but not used
  final bool isGrocery;
  final Widget? nextPage;
  final VoidCallback? onDeleted;
  final Color themeColor;
  final String listName;

  const HeroListDisplay({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isGrocery,
    this.nextPage,
    this.onDeleted,
    required this.themeColor,
    required this.listName,
  });

  @override
  State<HeroListDisplay> createState() => _HeroListDisplayState();
}

class _HeroListDisplayState extends State<HeroListDisplay> {
  GroceryList? _list;
  List<ListItem> _items = [];
  List<String> _topCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadList();
      }
    });
  }

  Future<void> _loadList() async {
    try {
      final list = await DatabaseService.getGroceryListByName(
        widget.title,
        !widget.isGrocery,
      );
      if (mounted) {
        setState(() {
          _list = list;
        });
        // Check if list needs image
        if (_list != null && (_list!.imagePath == null || _list!.imagePath!.isEmpty)) {
          ImageCheckService.checkListImage(_list!.name, widget.isGrocery);
        }
        if (mounted) {
          _loadItems();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _list = null;
        });
      }
    }
  }

  Future<void> _loadItems() async {
    try {
      final items = await DatabaseService.getListItems(
        widget.title,
        !widget.isGrocery,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _calculateTopCategories();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
          _topCategories = [];
        });
      }
    }
  }

  void _calculateTopCategories() {
    final categoryCounts = <String, int>{};
    for (final item in _items) {
      final category = ItemCategoryHelper.getItemCategory(item.name);
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }
    
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _topCategories = sortedCategories.take(5).map((e) => e.key).toList();
  }
  
  int get _uniqueItemCount => _items.map((e) => e.name).toSet().length;
  int get _totalItemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  String _getScheduleType() {
    if (_list == null || _list!.frequency == null) return 'No schedule';
    final freq = _list!.frequency;
    switch (freq!) {
      case ScheduleFrequency.once:
        return 'Once';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.biweekly:
        return 'Biweekly';
      case ScheduleFrequency.monthly:
        return 'Monthly';
    }
  }

  String _getNextDateText() {
    if (_list == null) return '';
    if (_list!.frequency == null) {
      if (_list!.scheduledDate != null) {
        return '${_list!.scheduledDate!.day}/${_list!.scheduledDate!.month}/${_list!.scheduledDate!.year}';
      }
      return '';
    }
    final nextDate = _list!.getNextShoppingDate();
    if (nextDate == null) return '';
    return '${nextDate.day}/${nextDate.month}/${nextDate.year}';
  }

  IconData _getListIcon() {
    if (_topCategories.isNotEmpty) {
      // Get icon for first item in the list
      if (_items.isNotEmpty) {
        return IconMappingService.getItemIcon(_items.first.name);
      }
    }
    return widget.isGrocery ? Icons.shopping_cart : Icons.inventory_2;
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    // Background color: slightly darker in light mode, slightly lighter in dark mode
    final backgroundColor = isDarkMode 
        ? Colors.grey[850]! // Slightly lighter than background
        : Colors.grey[100]!; // Slightly darker than background
    
    // Responsive sizing: min for phone, max for laptop
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 800.0 : double.infinity;
    // Icon-to-text ratio: 1:2 for all screens (icon = 1/3 of width)
    final iconWidth = screenWidth > 600 
        ? (maxWidth == double.infinity ? 266.0 : maxWidth / 3) 
        : (screenWidth / 3); // 1:2 ratio for smaller screens too

    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) {
          return GestureDetector(
            onTap: widget.nextPage != null
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => widget.nextPage!),
                  );
                }
                : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              width: maxWidth == double.infinity ? double.infinity : maxWidth.clamp(280.0, maxWidth),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Hero(
                tag: 'list_${widget.title}',
                child: Material(
                  color: Colors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left section - Icon or Image
                      Container(
                                width: iconWidth,
                                constraints: BoxConstraints(
                                  minWidth: 60.0,
                                  maxWidth: screenWidth > 600 ? 266.0 : (screenWidth / 3),
                                ),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14.0),
                                    bottomLeft: Radius.circular(14.0),
                                  ),
                                ),
                                child: ImageWithInfoIcon(
                                  imagePath: _list?.imagePath,
                                  fallbackAssetPath: widget.isGrocery 
                                      ? 'assets/images/grocery_background.jpg'
                                      : 'assets/images/inventory_background.jpg',
                                  identifier: widget.title,
                                  width: iconWidth,
                                  height: null, // Let it expand to fill parent
                                  fit: BoxFit.cover,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14.0),
                                    bottomLeft: Radius.circular(14.0),
                                  ),
                                  fallbackIcon: Icon(
                                    _getListIcon(),
                                    size: screenWidth > 600 ? 56 : 48,
                                    color: widget.themeColor,
                                  ),
                                ),
                              ),
                              // Spacing between image and text (5px for grocery lists)
                              SizedBox(width: widget.isGrocery ? 5.0 : 0.0),
                              // Right section - Text information
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: 0.0,
                                    maxWidth: double.infinity,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(14.0),
                                        bottomRight: Radius.circular(14.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                          children: [
                                          // List title
                                          Text(
                                            widget.title,
                                            style: TextStyleHelper.bodyBold(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          // Display items with their amounts
                                          if (_items.isEmpty)
                                            Text(
                                              'No items to display yet.',
                                              style: TextStyleHelper.small(
                                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                              ),
                                            )
                                          else ...[
                                            Text(
                                              'Items:',
                                              style: TextStyleHelper.small(
                                                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            ..._items.take(5).map((item) => Padding(
                                              padding: const EdgeInsets.only(bottom: 2),
                                              child: Text(
                                                '  • ${item.name} (${item.quantity} ${ItemUnits.getPluralizedUnit(item.name, item.quantity)})',
                                                style: TextStyleHelper.small(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )),
                                            if (_items.length > 5)
                                              Text(
                                                '  ... and ${_items.length - 5} more',
                                                style: TextStyleHelper.small(
                                                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                          const SizedBox(height: 5),
                                          // Schedule info (only for grocery lists)
                                          if (widget.isGrocery) ...[
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  fit: FlexFit.loose,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        _getScheduleType(),
                                                        style: TextStyleHelper.small(
                                                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (_getNextDateText().isNotEmpty) ...[
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          'Next: ${_getNextDateText()}',
                                                          style: TextStyleHelper.small(
                                                            color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.schedule, size: 18),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(
                                                    minWidth: 36,
                                                    minHeight: 36,
                                                  ),
                                                  onPressed: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) => SchedulingDialog(
                                                        list: _list,
                                                        onSave: (list) async {
                                                          final markedName = await DatabaseService.getGroceryListByName(
                                                            widget.title,
                                                            !widget.isGrocery,
                                                          );
                                                          if (markedName != null) {
                                                            list.id = markedName.id;
                                                            list.name = markedName.name;
                                                            list.isStockList = false;
                                                            await DatabaseService.updateGroceryList(list);
                                                            if (mounted) {
                                                              await _loadList();
                                                              setState(() {});
                                                            }
                                                            await NotificationService.scheduleShoppingReminders();
                                                            HomeRefreshService.refresh();
                                                            if (mounted) {
                                                              widget.onDeleted?.call();
                                                            }
                                                          }
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  tooltip: 'Edit Schedule',
                                                ),
                                              ],
                                            ),
                                          ],
                                          // Delete button (for both grocery and stock lists)
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(
                                                  minWidth: 36,
                                                  minHeight: 36,
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (ctx) => ValueListenableBuilder<double>(
                                                      valueListenable: PreferencesService.textSize,
                                                      builder: (context, textSize, _) => AlertDialog(
                                                        title: Text('Confirm Delete', style: TextStyleHelper.h4()),
                                                        content: Text('Delete "${widget.title}"?', style: TextStyleHelper.body()),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(ctx).pop(),
                                                            child: Text('Cancel', style: TextStyleHelper.body()),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              Navigator.of(ctx).pop();
                                                              await deleteList(widget.listName, widget.title, !widget.isGrocery);
                                                              if (mounted) {
                                                                widget.onDeleted?.call();
                                                              }
                                                            },
                                                            child: Text('Delete', style: TextStyleHelper.body()),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                tooltip: 'Delete List',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
