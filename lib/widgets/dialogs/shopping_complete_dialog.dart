import 'package:flutter/material.dart';
import 'package:grocer_app/models/list_item.dart';
import 'package:grocer_app/models/grocery_list.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/services/notification_service.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';

class ShoppingCompleteDialog extends StatefulWidget {
  final List<ListItem> items;
  final String listName;

  const ShoppingCompleteDialog({
    super.key,
    required this.items,
    required this.listName,
  });

  @override
  State<ShoppingCompleteDialog> createState() => _ShoppingCompleteDialogState();
}

class _ShoppingCompleteDialogState extends State<ShoppingCompleteDialog> {
  String? _selectedStockList;
  String? _newStockListName;
  bool _createNewStock = false;
  List<String> _stockLists = [];

  @override
  void initState() {
    super.initState();
    _loadStockLists();
  }

  Future<void> _loadStockLists() async {
    final lists = await DatabaseService.getStockLists();
    if (mounted) {
      setState(() {
        _stockLists = lists.map((l) => l.name).toList();
        if (_stockLists.isNotEmpty && !_createNewStock) {
          _selectedStockList = _stockLists.first;
        }
      });
    }
  }

  Future<void> _completeShopping() async {
    if (_createNewStock) {
      if (_newStockListName == null || _newStockListName!.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a stock list name', style: TextStyleHelper.body())),
        );
        return;
      }
      // Create new stock list
      await DatabaseService.addGroceryList(_newStockListName!.trim(), true);
      _selectedStockList = _newStockListName!.trim();
    }

    if (_selectedStockList == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a stock list', style: TextStyleHelper.body())),
      );
      return;
    }

    // Transfer all bought items to stock
    for (final item in widget.items) {
      if (item.bought) {
        // Check if item already exists in stock
        final stockItems = await DatabaseService.getListItems(_selectedStockList!, true);
        final existingItem = stockItems.firstWhere(
          (stockItem) => stockItem.name == item.name,
          orElse: () => ListItem(listName: '', name: '', quantity: 0, id: -1),
        );

        if (existingItem.id > 0) {
          // Update existing item quantity
          existingItem.quantity += item.quantity;
          await DatabaseService.updateListItem(existingItem);
        } else {
          // Create new item in stock
          await DatabaseService.addListItem(
            _selectedStockList!,
            true,
            item.name,
            item.quantity,
          );
        }
      }
    }

    // Mark list as completed and update next shopping date
    final list = await DatabaseService.getGroceryListByName(widget.listName, false);
    if (list != null) {
      list.isCompleted = true;
      list.lastCompletedDate = DateTime.now();
      
      // Update next shopping date for recurring lists
      if (list.frequency != null && list.frequency != ScheduleFrequency.once) {
        final nextDate = list.getNextShoppingDate();
        if (nextDate != null) {
          list.scheduledDate = nextDate;
        }
      }
      
      await DatabaseService.updateGroceryList(list);
      
      // Reschedule notifications after completion
      await NotificationService.scheduleShoppingReminders();
    }

    // Clear bought status from shopping list items
    for (final item in widget.items) {
      if (item.bought) {
        item.bought = false;
        await DatabaseService.updateListItem(item);
      }
    }

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate completion
    }
  }

  @override
  Widget build(BuildContext context) {
    final boughtItems = widget.items.where((item) => item.bought).toList();
    
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('Complete Shopping', style: TextStyleHelper.h4()),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${boughtItems.length} item(s) will be added to stock:',
                style: TextStyleHelper.body(),
              ),
              const SizedBox(height: 8),
              ...boughtItems.take(5).map((item) => Text(
                '• ${item.name} (${item.quantity})',
                style: TextStyleHelper.small(),
              )),
              if (boughtItems.length > 5)
                Text('... and ${boughtItems.length - 5} more', style: TextStyleHelper.small()),
              const SizedBox(height: 16),
              RadioListTile<bool>(
                title: Text('Add to existing stock', style: TextStyleHelper.body()),
                value: false,
                groupValue: _createNewStock,
                onChanged: (value) {
                  setState(() {
                    _createNewStock = false;
                    if (_stockLists.isNotEmpty) {
                      _selectedStockList = _stockLists.first;
                    }
                  });
                },
              ),
              if (!_createNewStock) ...[
                if (_stockLists.isEmpty)
                  Text('No stock lists available', style: TextStyleHelper.small(color: Colors.grey))
                else
                  DropdownButton<String>(
                    value: _selectedStockList,
                    isExpanded: true,
                    items: _stockLists.map((name) => DropdownMenuItem(
                      value: name,
                      child: Text(name, style: TextStyleHelper.body()),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStockList = value;
                      });
                    },
                  ),
              ],
              RadioListTile<bool>(
                title: Text('Create new stock list', style: TextStyleHelper.body()),
                value: true,
                groupValue: _createNewStock,
                onChanged: (value) {
                  setState(() {
                    _createNewStock = true;
                    _selectedStockList = null;
                  });
                },
              ),
              if (_createNewStock)
                TextField(
                  style: TextStyleHelper.body(),
                  decoration: InputDecoration(
                    hintText: 'Stock list name',
                    hintStyle: TextStyleHelper.body(color: Colors.grey),
                  ),
                  onChanged: (value) {
                    _newStockListName = value;
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyleHelper.body()),
          ),
          ElevatedButton(
            onPressed: boughtItems.isEmpty ? null : _completeShopping,
            child: Text('Complete', style: TextStyleHelper.body()),
          ),
        ],
        ),
        ),
      );
  }
}

