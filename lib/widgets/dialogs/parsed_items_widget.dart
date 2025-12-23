import 'package:flutter/material.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';

/// Separate widget that manages its own state for displaying parsed items
/// This allows the AlertDialog to continue listening while items update
class ParsedItemsWidget extends StatefulWidget {
  final List<ParsedItem> items;
  final ValueNotifier<List<ParsedItem>>? itemsNotifier;

  const ParsedItemsWidget({
    super.key,
    this.items = const [],
    this.itemsNotifier,
  });

  @override
  State<ParsedItemsWidget> createState() => _ParsedItemsWidgetState();
}

class _ParsedItemsWidgetState extends State<ParsedItemsWidget> {
  final List<ParsedItem> _currentItems = [];

  @override
  void initState() {
    super.initState();
    _currentItems.addAll(widget.items);
    
    // Listen to notifier if provided
    widget.itemsNotifier?.addListener(_addNewItems);
  }

  @override
  void didUpdateWidget(ParsedItemsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only add new items from widget.items, don't replace
    if (widget.items.length > _currentItems.length) {
      final newItems = widget.items.skip(_currentItems.length).toList();
      setState(() {
        _currentItems.addAll(newItems);
      });
    }
    
    // Update listener if notifier changed
    if (widget.itemsNotifier != oldWidget.itemsNotifier) {
      oldWidget.itemsNotifier?.removeListener(_addNewItems);
      widget.itemsNotifier?.addListener(_addNewItems);
    }
  }

  void _addNewItems() {
    if (mounted && widget.itemsNotifier != null) {
      final notifierItems = widget.itemsNotifier!.value;
      // Only add items that aren't already in the list
      // Compare by name to avoid duplicates
      final existingNames = _currentItems.map((item) => item.name.toLowerCase()).toSet();
      final newItems = notifierItems.where((item) => 
        !existingNames.contains(item.name.toLowerCase())
      ).toList();
      
      if (newItems.isNotEmpty) {
        setState(() {
          _currentItems.addAll(newItems);
        });
      }
    }
  }

  @override
  void dispose() {
    widget.itemsNotifier?.removeListener(_addNewItems);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PreferencesService.isDarkMode,
      builder: (context, isDarkMode, _) {
        if (_currentItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text('Recognized items:', style: TextStyleHelper.bodyBold()),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _currentItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < _currentItems.length - 1 ? 8 : 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyleHelper.body(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[700] : Colors.white,
                          ),
                          child: Text(
                            item.quantity ?? '1',
                            style: TextStyleHelper.bodyBold(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

