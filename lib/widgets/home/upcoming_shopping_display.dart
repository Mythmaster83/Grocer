import 'package:flutter/material.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/models/grocery_list.dart';
import 'package:grocer_app/models/list_item.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/data/item_units.dart';
import 'package:grocer_app/services/home_refresh_service.dart';
import 'package:grocer_app/pages/view_port.dart';

class UpcomingShoppingDisplay extends StatefulWidget {
  final Color adjustedContainerColor;
  final double textSize;
  final Color themeColor;
  final bool isDarkMode;
  final VoidCallback? onRefresh;

  const UpcomingShoppingDisplay({
    super.key,
    required this.adjustedContainerColor,
    required this.textSize,
    required this.themeColor,
    required this.isDarkMode,
    this.onRefresh,
  });

  @override
  State<UpcomingShoppingDisplay> createState() => _UpcomingShoppingDisplayState();
}

class _UpcomingShoppingDisplayState extends State<UpcomingShoppingDisplay> {
  Map<DateTime, List<GroceryList>>? _upcomingLists;
  Map<String, List<ListItem>>? _listItems;

  @override
  void initState() {
    super.initState();
    _loadUpcomingShopping();
    // Listen to refresh notifications
    HomeRefreshService.refreshNotifier.addListener(_onRefresh);
  }

  @override
  void dispose() {
    HomeRefreshService.refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) {
      _loadUpcomingShopping();
    }
  }


  Future<void> _loadUpcomingShopping() async {
    final upcoming = await DatabaseService.getUpcomingShoppingLists();
    final itemsMap = <String, List<ListItem>>{};

    // Debug: Print what we're getting
    debugPrint('[UpcomingShoppingDisplay] Loaded ${upcoming.length} date groups');
    for (final entry in upcoming.entries) {
      debugPrint('[UpcomingShoppingDisplay] Date: ${entry.key}, Lists: ${entry.value.length}');
      for (final list in entry.value) {
        debugPrint('[UpcomingShoppingDisplay]   - List: ${list.name}');
      }
    }

    // Load items for each list (all are shopping lists, so isStockList = false)
    // Note: list.name is already display name, and getListItems expects display name
    for (final lists in upcoming.values) {
      for (final list in lists) {
        // getListItems expects display name and will convert to marked name internally
        final items = await DatabaseService.getListItems(list.name, false);
        debugPrint('[UpcomingShoppingDisplay] List "${list.name}" has ${items.length} items');
        
        // Filter out invalid items - be less strict for debugging
        final validItems = items.where((item) => 
          item.id > 0 && 
          item.name.isNotEmpty && 
          item.name.trim().isNotEmpty
          // Allow quantity = 0 for debugging, but prefer quantity > 0
        ).toList();
        
        debugPrint('[UpcomingShoppingDisplay] List "${list.name}" has ${validItems.length} valid items');
        if (validItems.isNotEmpty) {
          for (final item in validItems.take(3)) {
            debugPrint('[UpcomingShoppingDisplay]   - Item: ${item.name}, quantity: ${item.quantity}');
          }
        }
        
        itemsMap[list.name] = validItems; // Use display name as key for lookup
      }
    }

    debugPrint('[UpcomingShoppingDisplay] Total lists with items: ${itemsMap.length}');

    if (mounted) {
      setState(() {
        _upcomingLists = upcoming;
        _listItems = itemsMap;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getFrequencyText(ScheduleFrequency? freq) {
    if (freq == null) return '';
    switch (freq) {
      case ScheduleFrequency.once:
        return ' (One-time)';
      case ScheduleFrequency.weekly:
        return ' (Weekly)';
      case ScheduleFrequency.biweekly:
        return ' (Biweekly)';
      case ScheduleFrequency.monthly:
        return ' (Monthly)';
    }
  }

  Widget _buildShoppingDayCard(DateTime date, List<GroceryList> listsForDate) {
    // Merge all items from lists on this date
    final allItems = <String, int>{};
    for (final list in listsForDate) {
      final items = _listItems?[list.name] ?? [];
      debugPrint('[UpcomingShoppingDisplay] Building card for list "${list.name}" with ${items.length} items');
      
      // Debug: Check if items exist but are empty
      if (items.isEmpty) {
        if (_listItems?.containsKey(list.name) == true) {
          debugPrint('[UpcomingShoppingDisplay] List "${list.name}" has no items (empty list)');
        } else {
          debugPrint('[UpcomingShoppingDisplay] List "${list.name}" not found in _listItems map');
        }
        continue;
      }
      
      for (final item in items) {
        // Show all items, not just unbought ones
        // Only add valid items - be less strict: allow quantity = 0 for now
        if (item.id > 0 && item.name.isNotEmpty && item.name.trim().isNotEmpty) {
          // Sum quantities - include even if 0 to see what's happening
          final quantity = item.quantity > 0 ? item.quantity : 0;
          allItems[item.name] = (allItems[item.name] ?? 0) + quantity;
          if (quantity == 0) {
            debugPrint('[UpcomingShoppingDisplay] Item "${item.name}" has quantity 0');
          }
        } else {
          debugPrint('[UpcomingShoppingDisplay] Invalid item: id=${item.id}, name="${item.name}", quantity=${item.quantity}');
        }
      }
    }
    
    debugPrint('[UpcomingShoppingDisplay] Card for date $date has ${allItems.length} unique items, total quantity: ${allItems.values.fold(0, (sum, qty) => sum + qty)}');

    return GestureDetector(
      onTap: () {
        // Navigate to the first list on this date
        if (listsForDate.isNotEmpty) {
          final firstList = listsForDate.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewPort(
                title: firstList.name,
                themeColor: widget.themeColor,
                isGrocery: true,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 370,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.adjustedContainerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(date),
            style: TextStyleHelper.h4(color: widget.themeColor),
            textAlign: TextAlign.center,
          ),
          if (listsForDate.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${listsForDate.length} lists merged',
                style: TextStyleHelper.small(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 12),
          ...listsForDate.map((list) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${list.name}${_getFrequencyText(list.frequency)}',
              style: TextStyleHelper.body(),
            ),
          )),
          if (allItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Items:',
              style: TextStyleHelper.bodyBold(),
            ),
            const SizedBox(height: 4),
            ...allItems.entries.take(10).map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '  • ${entry.key} (${entry.value} ${ItemUnits.getPluralizedUnit(entry.key, entry.value)})',
                style: TextStyleHelper.small(),
              ),
            )),
            if (allItems.length > 10)
              Text(
                '  ... and ${allItems.length - 10} more',
                style: TextStyleHelper.small(color: Colors.grey),
              ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'No items to display yet.',
              style: TextStyleHelper.small(color: Colors.grey),
            ),
          ],
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_upcomingLists == null || _upcomingLists!.isEmpty) {
      return Container(
        width: 370,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: widget.adjustedContainerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Upcoming Shopping Days',
              style: TextStyleHelper.h4(color: widget.themeColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming shopping scheduled.',
              style: TextStyleHelper.body(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Get sorted dates - show future/current dates first
    // Normalize today for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Filter and sort dates - dates in _upcomingLists are already normalized
    final sortedDates = _upcomingLists!.keys
        .where((d) {
          // Normalize the date for comparison
          final normalized = DateTime(d.year, d.month, d.day);
          return !normalized.isBefore(today); // Include today and future dates
        })
        .toList()
      ..sort();
    
    debugPrint('[UpcomingShoppingDisplay] Sorted dates count: ${sortedDates.length}');
    for (final date in sortedDates) {
      debugPrint('[UpcomingShoppingDisplay] Date: $date, Lists: ${_upcomingLists![date]?.length ?? 0}');
    }

    // Return scrollable list of shopping days
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: sortedDates.length,
        itemBuilder: (context, index) {
          final date = sortedDates[index];
          final listsForDate = _upcomingLists![date]!;
          return _buildShoppingDayCard(date, listsForDate);
        },
      ),
    );
  }
}

