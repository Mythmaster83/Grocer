import 'package:flutter/material.dart';
import 'package:grocer_app/pages/view_port.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:grocer_app/widgets/hero_list_display.dart';
import 'package:grocer_app/services/home_refresh_service.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/widgets/dialogs/scheduling_dialog.dart';
import 'package:grocer_app/services/notification_service.dart';
import 'package:grocer_app/widgets/add_list_ghost_widget.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/widgets/dialogs/voice_input_dialog.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/widgets/dialogs/duplicate_list_dialog.dart';

class ShoppingListsPage extends StatefulWidget {
  const ShoppingListsPage({super.key});

  @override
  State<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends State<ShoppingListsPage> {
  List<String> _shoppingLists = [];

  @override
  void initState() {
    super.initState();
    _loadShoppingLists();
  }

  Future<void> _loadShoppingLists() async {
    final lists = await DatabaseService.getShoppingLists();
    if (!mounted) return;
    setState(() {
      // Filter out empty or null names to prevent rendering issues
      _shoppingLists = lists
          .map((l) => l.name)
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }

  void _addShoppingList(BuildContext context) async {
    final controller = TextEditingController();
    String? name = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: PreferencesService.textSize,
        builder: (context, textSize, _) => ValueListenableBuilder<bool>(
          valueListenable: PreferencesService.isDarkMode,
            builder: (context, isDarkMode, _) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            title: Text('New Shopping List', style: TextStyleHelper.h4()),
          content: TextField(
            controller: controller,
            style: TextStyleHelper.body(),
            decoration: InputDecoration(
              hintText: 'List name',
              hintStyle: TextStyleHelper.body(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyleHelper.body()),
            ),
            ElevatedButton(
              onPressed: () {
                final inputName = controller.text.trim();
                if (inputName.isNotEmpty) {
                  Navigator.pop(context, inputName);
                }
              },
              child: Text('Next', style: TextStyleHelper.body()),
            ),
          ],
        ),
          ),
        ),
      );

    if (name != null && name.isNotEmpty && mounted) {
      // Check for duplicate
      final exists = await DatabaseService.listExists(name, false);
      if (exists) {
        if (!context.mounted) return;
        final action = await DuplicateListDialog.show(context, name, false);
        if (action == null || !context.mounted) return; // Canceled
        
        if (action == 'replace') {
          // Delete existing list and create new one
          await DatabaseService.deleteGroceryList(name, false);
        } else if (action == 'rename') {
          // Show rename dialog
          if (!context.mounted) return;
          final renameController = TextEditingController(text: name);
          final newName = await showDialog<String>(
            context: context,
            barrierColor: Colors.black54,
            builder: (_) => ValueListenableBuilder<double>(
              valueListenable: PreferencesService.textSize,
              builder: (context, textSize, _) => ValueListenableBuilder<bool>(
                valueListenable: PreferencesService.isDarkMode,
                builder: (context, isDarkMode, _) => AlertDialog(
                  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                  title: Text('Rename List', style: TextStyleHelper.h4()),
                  content: TextField(
                    controller: renameController,
                    style: TextStyleHelper.body(),
                    decoration: InputDecoration(
                      hintText: 'New list name',
                      hintStyle: TextStyleHelper.body(color: Colors.grey),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyleHelper.body()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final newNameValue = renameController.text.trim();
                        if (newNameValue.isNotEmpty) {
                          Navigator.pop(context, newNameValue);
                        }
                      },
                      child: Text('Rename', style: TextStyleHelper.body()),
                    ),
                  ],
                ),
              ),
            ),
          );
          if (newName == null || newName.isEmpty || !mounted) return;
          name = newName;
        }
      }
      
      // Create the list
      await DatabaseService.addGroceryList(name, false);
      
      // Get the created list and show scheduling dialog
      final list = await DatabaseService.getGroceryListByName(name, false);
      if (!mounted) return;
      if (list != null) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => SchedulingDialog(
            list: list,
            onSave: (updatedList) async {
              // Name is already set with marker, just ensure isStockList is correct
              updatedList.isStockList = false;
              await DatabaseService.updateGroceryList(updatedList);
              if (mounted) {
                await _loadShoppingLists();
              }
              // Reschedule notifications
              await NotificationService.scheduleShoppingReminders();
            },
          ),
        );
        if (mounted) {
          await _loadShoppingLists();
        }
      }
    }
  }

  Future<void> _handleVoiceInput() async {
    final result = await showDialog<List<ParsedItem>>(
      context: context,
      builder: (context) => const VoiceInputDialog(isStockList: false),
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Prompt for list name
      final controller = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => ValueListenableBuilder<double>(
          valueListenable: PreferencesService.textSize,
          builder: (context, textSize, _) => ValueListenableBuilder<bool>(
            valueListenable: PreferencesService.isDarkMode,
            builder: (context, isDarkMode, _) => AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              title: Text('New Shopping List', style: TextStyleHelper.h4()),
              content: TextField(
                controller: controller,
                style: TextStyleHelper.body(),
                decoration: InputDecoration(
                  hintText: 'Shopping list name',
                  hintStyle: TextStyleHelper.body(color: Colors.grey),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyleHelper.body()),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context, name);
                    }
                  },
                  child: Text('Next', style: TextStyleHelper.body()),
                ),
              ],
            ),
          ),
        ),
      );

      if (name != null && name.isNotEmpty && mounted) {
        // Check for duplicate
        final exists = await DatabaseService.listExists(name, false);
        if (exists) {
          if (!mounted || !context.mounted) return;
          final action = await DuplicateListDialog.show(context, name, false);
          if (action == null || !mounted || !context.mounted) return; // Canceled
          
          if (action == 'replace') {
            await DatabaseService.deleteGroceryList(name, false);
          } else if (action == 'rename') {
            // User chose to rename, but we already have the name from dialog
            // Just continue with the name they provided
          }
        }
        
        // Create the list first
        await DatabaseService.addGroceryList(name, false);
        
        // Add items to the list
        for (final item in result) {
          final quantity = item.quantity == '.' ? 1 : int.tryParse(item.quantity ?? '1') ?? 1;
          await DatabaseService.addListItem(name, false, item.name, quantity);
        }
        
        // Get the created list and show scheduling dialog
        final list = await DatabaseService.getGroceryListByName(name, false);
        if (!mounted) return;
        if (list != null) {
          if (!context.mounted) return;
          await showDialog(
            context: context,
            builder: (context) => SchedulingDialog(
              list: list,
              onSave: (updatedList) async {
                // Get the marked name for the list
                final markedName = await DatabaseService.getGroceryListByName(name, false);
                if (markedName != null) {
                  updatedList.id = markedName.id;
                  updatedList.name = markedName.name; // Keep the marked name
                  updatedList.isStockList = false;
                  await DatabaseService.updateGroceryList(updatedList);
                  // Refresh homepage
                  HomeRefreshService.refresh();
                  if (mounted) {
                    await _loadShoppingLists();
                  }
                  // Reschedule notifications
                  await NotificationService.scheduleShoppingReminders();
                }
              },
            ),
          );
          if (mounted) {
            await _loadShoppingLists();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) {
        return ValueListenableBuilder<String>(
          valueListenable: PreferencesService.fontFamily,
          builder: (context, fontFamily, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: PreferencesService.themeColor,
          builder: (context, themeColor, _) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  centerTitle: true,
                  title: Text(
                    'Shopping Lists',
                    style: TextStyleHelper.h3(),
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: _handleVoiceInput,
                  backgroundColor: themeColor,
                  child: const Icon(Icons.mic),
                ),
                body: _shoppingLists.isEmpty
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        'No shopping lists yet.',
                        style: TextStyleHelper.body(),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _addShoppingList(context),
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    )
                  ],
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate maxWidth to match hero_list_display
                    final screenWidth = MediaQuery.of(context).size.width;
                    final maxWidth = screenWidth > 600 ? 800.0 : double.infinity;
                    
                    return ListView.builder(
                      key: ValueKey('shopping_lists_${_shoppingLists.length}'),
                      padding: const EdgeInsets.all(14),
                      itemCount: _shoppingLists.length + 1,
                      // +1 for ghost widget
                      itemBuilder: (context, index) {
                        // Bounds check
                        if (index < 0 || index > _shoppingLists.length) {
                          return const SizedBox(
                              height: 1, width: double.infinity);
                        }

                        // Ghost widget at the end
                        if (index == _shoppingLists.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: 280.0,
                                maxWidth: maxWidth,
                                minHeight: 50.0,
                                maxHeight: 75.0,
                            ),
                            child: AddListGhostWidget(
                              key: const ValueKey('add_shopping_widget'),
                              onAdd: () => _addShoppingList(context),
                              caption: 'Add New Shopping List',
                              ),
                            ),
                          );
                        }

                        // Regular list item
                        if (index < 0 || index >= _shoppingLists.length) {
                          return const SizedBox(
                              height: 1, width: double.infinity);
                        }

                        final listName = _shoppingLists[index];
                        if (listName.isEmpty) {
                          return const SizedBox(
                              height: 1, width: double.infinity);
                        }

                        // Build list widget with constraints
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: 280.0,
                              maxWidth: maxWidth,
                            ),
                            child: IntrinsicHeight(
                              child: HeroListDisplay(
                                key: ValueKey('shopping_list_$listName'),
                                nextPage: ViewPort(
                                  title: listName,
                                  themeColor: themeColor,
                                  isGrocery: true,
                                ),
                                title: listName,
                                imagePath: 'assets/images/grocery_background.jpg',
                                isGrocery: true,
                                listName: 'shoppingLists',
                                onDeleted: () => _loadShoppingLists(),
                                themeColor: themeColor,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
            );
          }
        );
      },
        );
      },
    );
  }
}
