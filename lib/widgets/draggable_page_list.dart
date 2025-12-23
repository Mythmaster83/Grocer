import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/text_style_helper.dart';

class DraggablePageList extends StatefulWidget {
  const DraggablePageList({super.key});

  @override
  State<DraggablePageList> createState() => _DraggablePageListState();
}

class _DraggablePageListState extends State<DraggablePageList> {
  String _labelForPage(String key) {
    switch (key) {
      case 'home':
        return 'Home';
      case 'stock':
        return 'Stock';
      case 'lists':
        return 'Lists';
      case 'settings':
        return 'Settings';
      default:
        return key;
    }
  }

  Icon _iconForPage(String key) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black87;
    switch (key) {
      case 'home':
        return Icon(Icons.home, color: iconColor);
      case 'stock':
        return Icon(Icons.inventory_2, color: iconColor);
      case 'lists':
        return Icon(Icons.list_alt, color: iconColor);
      case 'settings':
        return Icon(Icons.settings, color: iconColor);
      default:
        return Icon(Icons.help_outline, color: iconColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    final backgroundColor = isDarkMode 
        ? Theme.of(context).colorScheme.surface 
        : Colors.grey[200];
    
    return ValueListenableBuilder<List<String>>(
      valueListenable: PreferencesService.pageOrder,
      builder: (context, pages, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Page Order',
              style: TextStyleHelper.h4(),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final newOrder = List<String>.from(pages);
                final item = newOrder.removeAt(oldIndex);
                newOrder.insert(newIndex, item);
                PreferencesService.savePageOrder(newOrder);
              },
              children: pages.asMap().entries.map((entry) {
                final index = entry.key;
                final pageKey = entry.value;
                return Container(
                  key: ValueKey('$pageKey-$index'),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).round()),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: _iconForPage(pageKey),
                    title: Text(_labelForPage(pageKey), style: TextStyleHelper.body()),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
