import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/text_style_helper.dart';
import '../../services/preferences_service.dart';
import '../item_autocomplete_field.dart';

class AddItemDialog extends StatefulWidget {
  final String listName;
  final bool isStockList;
  final Function(String name, int quantity) onAdd;

  const AddItemDialog({
    super.key,
    required this.listName,
    required this.isStockList,
    required this.onAdd,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  // Controllers owned by dialog state - created once, disposed once
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final name = _nameController.text.trim();
    final quantityText = _quantityController.text.trim();
    // Handle dots as ambiguous quantity (default to 1)
    final quantity = (quantityText.isEmpty || quantityText == '.') 
        ? 1 
        : int.tryParse(quantityText) ?? 1;

    if (name.isNotEmpty) {
      widget.onAdd(name, quantity);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read preferences once, don't rebuild on changes
    final isDarkMode = PreferencesService.isDarkMode.value;
    
    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
      title: Text('Add Item', style: TextStyleHelper.h4()),
      content: SizedBox(
        // Fixed height to prevent collapse
        height: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ItemAutocompleteField(
              controller: _nameController,
              hintText: 'Item name',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              style: TextStyleHelper.body(),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: InputDecoration(
                hintText: 'Quantity',
                hintStyle: TextStyleHelper.body(color: Colors.grey),
              ),
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
          onPressed: _handleAdd,
          child: Text('Add', style: TextStyleHelper.body()),
        ),
      ],
    );
  }
}
