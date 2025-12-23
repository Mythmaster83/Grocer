import 'package:flutter/material.dart';
import 'package:grocer_app/pages/view_port.dart';
import 'package:grocer_app/widgets/hero_list_display.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/widgets/add_list_ghost_widget.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/widgets/dialogs/voice_input_dialog.dart';
import 'package:grocer_app/services/speech_service.dart';
import 'package:grocer_app/widgets/dialogs/duplicate_list_dialog.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<String> _stockLists = [];

  @override
  void initState() {
    super.initState();
    _loadStockLists();
  }

  Future<void> _loadStockLists() async {
    final lists = await DatabaseService.getStockLists();
    if (!mounted) return;
    setState(() {
      // Filter out empty or null names to prevent rendering issues
      _stockLists = lists
          .map((l) => l.name)
          .where((name) => name.isNotEmpty)
          .toList();
    });
  }


  void _addStockList(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: PreferencesService.textSize,
        builder: (context, textSize, _) => ValueListenableBuilder<bool>(
          valueListenable: PreferencesService.isDarkMode,
          builder: (context, isDarkMode, _) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            title: Text('New Stock List', style: TextStyleHelper.h4()),
          content: TextField(
            controller: controller,
            style: TextStyleHelper.body(),
            decoration: InputDecoration(
              hintText: 'Stock name',
              hintStyle: TextStyleHelper.body(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyleHelper.body()),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  // Check for duplicate
                  final exists = await DatabaseService.listExists(name, true);
                  if (exists) {
                    if (!context.mounted) return;
                    Navigator.pop(context); // Close name dialog first
                    if (!context.mounted) return;
                    final action = await DuplicateListDialog.show(context, name, true);
                    if (action == null || !mounted) return; // Canceled
                    
                    if (action == 'replace') {
                      await DatabaseService.deleteGroceryList(name, true);
                    } else if (action == 'rename') {
                      // Show rename dialog
                      if (!context.mounted) return;
                      final renameController = TextEditingController(text: name);
                      final newName = await showDialog<String>(
                        context: context,
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
                      // Use new name
                      await DatabaseService.addGroceryList(newName, true);
                      if (!mounted) return;
                      await _loadStockLists();
                      if (!mounted) return;
                      return;
                    }
                  }
                  
                  await DatabaseService.addGroceryList(name, true);
                  if (!mounted) return;
                  await _loadStockLists();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } else {
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: TextStyleHelper.body()),
            ),
          ],
        ),
          ),
        ),
      );
  }

  Future<void> _handleVoiceInput() async {
    final result = await showDialog<List<ParsedItem>>(
      context: context,
      builder: (context) => const VoiceInputDialog(isStockList: true),
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Prompt for list name
      final controller = TextEditingController();
      final name = await showDialog<String>(
        context: context,
        builder: (_) => ValueListenableBuilder<double>(
          valueListenable: PreferencesService.textSize,
          builder: (context, textSize, _) => ValueListenableBuilder<bool>(
            valueListenable: PreferencesService.isDarkMode,
            builder: (context, isDarkMode, _) => AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
              title: Text('New Stock List', style: TextStyleHelper.h4()),
              content: TextField(
                controller: controller,
                style: TextStyleHelper.body(),
                decoration: InputDecoration(
                  hintText: 'Stock list name',
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
                  child: Text('Create', style: TextStyleHelper.body()),
                ),
              ],
            ),
          ),
        ),
      );

      if (name != null && name.isNotEmpty && mounted) {
        // Check for duplicate - use mutable variable
        String finalName = name;
        final exists = await DatabaseService.listExists(finalName, true);
        if (exists) {
          if (!mounted || !context.mounted) return;
          final action = await DuplicateListDialog.show(context, finalName, true);
          if (action == null || !mounted || !context.mounted) return; // Canceled
          
          if (action == 'replace') {
            await DatabaseService.deleteGroceryList(finalName, true);
          } else if (action == 'rename') {
            // Show rename dialog
            if (!mounted || !context.mounted) return;
            final renameController = TextEditingController(text: finalName);
            if (!mounted || !context.mounted) return;
            final newName = await showDialog<String>(
              context: context,
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
            finalName = newName;
          }
        }
        
        // Create the stock list
        await DatabaseService.addGroceryList(finalName, true);
        
        // Add items to the list
        for (final item in result) {
          final quantity = item.quantity == '.' ? 1 : int.tryParse(item.quantity ?? '1') ?? 1;
          await DatabaseService.addListItem(finalName, true, item.name, quantity);
        }
        
        if (mounted) {
          await _loadStockLists();
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
                  'Stock Lists',
                  style: TextStyleHelper.h3(),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _handleVoiceInput,
                backgroundColor: themeColor,
                child: const Icon(Icons.mic),
              ),
              body: _stockLists.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'No stock lists yet.',
                            style: TextStyleHelper.body(),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _addStockList(context),
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
                      key: ValueKey('stock_lists_${_stockLists.length}'),
                      padding: const EdgeInsets.all(14),
                      itemCount: _stockLists.length + 1, // +1 for ghost widget
                      itemBuilder: (context, index) {
                        // Bounds check
                        if (index < 0 || index > _stockLists.length) {
                          return const SizedBox(height: 1);
                        }
                        
                        // Ghost widget at the end
                        if (index == _stockLists.length) {
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
                            key: const ValueKey('add_stock_widget'),
                            onAdd: () => _addStockList(context),
                            caption: 'Add New Stock List',
                                  ),
                                ),
                          );
                        }
                        
                        // Regular list item
                        if (index < 0 || index >= _stockLists.length) {
                          return const SizedBox(height: 1);
                        }
                        
                        final stockName = _stockLists[index];
                        if (stockName.isEmpty) {
                          return const SizedBox(height: 1);
                        }
                        
                        // Build list widget
                            return Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: 280.0,
                                  maxWidth: maxWidth,
                                ),
                                child: IntrinsicHeight(
                                  child: HeroListDisplay(
                                    key: ValueKey('stock_list_$stockName'),
                                    nextPage: ViewPort(
                                    title: stockName,
                                    themeColor: themeColor,
                                    isGrocery: false,
                                    ),
                                    title: stockName,
                                    imagePath: 'assets/images/inventory_background.jpg',
                                    isGrocery: false,
                                    listName: 'stockLists',
                                    onDeleted: () => _loadStockLists(),
                                    themeColor: themeColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            );
          },
            );
          },
        );
      },
    );
  }
}
