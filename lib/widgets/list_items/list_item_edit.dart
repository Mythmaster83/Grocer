import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/text_style_helper.dart';
import '../../services/preferences_service.dart';
import '../../services/icon_mapping_service.dart';
import '../../data/item_units.dart';
import '../../widgets/image_with_info_icon.dart';

class ListItemEdit extends StatefulWidget {
  final String name;
  final int quantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onDelete;
  final Color themeColor;
  final String? imagePath;

  const ListItemEdit({
    super.key,
    required this.name,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onDelete,
    required this.themeColor,
    this.imagePath,
  });

  @override
  State<ListItemEdit> createState() => _ListItemEditState();
}

class _ListItemEditState extends State<ListItemEdit> {
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late FocusNode _quantityFocusNode;

  // Calculate item height based on text size and screen width
  double _calculateItemHeight(double textSize, double screenWidth) {
    // Base height calculation: text size * multiplier + padding
    final baseHeight = (textSize * 4.5) + 40; // Base calculation
    // Minimum height
    final minHeight = baseHeight+15;
    // Maximum height based on screen width
    final maxHeight = screenWidth > 600 ? 240.0 : 200.0;
    // Clamp between min and max
    return baseHeight.clamp(minHeight, maxHeight);
  }

  @override
  void initState() {
    super.initState();
    // Ensure quantity is valid
    final validQuantity = widget.quantity > 0 ? widget.quantity : 1;
    _quantityController = TextEditingController(text: validQuantity.toString());
    final unit = ItemUnits.getUnit(widget.name);
    _unitController = TextEditingController(text: unit.isNotEmpty ? unit : 'unit');
    _quantityFocusNode = FocusNode();
    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        _saveQuantity();
      }
    });
  }

  @override
  void didUpdateWidget(ListItemEdit oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if quantity actually changed and is valid
    if (oldWidget.quantity != widget.quantity && widget.quantity > 0) {
      final validQuantity = widget.quantity > 0 ? widget.quantity : 1;
      if (_quantityController.text != validQuantity.toString()) {
        _quantityController.text = validQuantity.toString();
      }
    }
    // Update unit if name changed
    if (oldWidget.name != widget.name) {
      final unit = ItemUnits.getUnit(widget.name);
      if (unit.isNotEmpty && _unitController.text != unit) {
        _unitController.text = unit;
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  void _saveQuantity() {
    final text = _quantityController.text.trim();
    if (text.isEmpty || text == '.' || text == '-') {
      // Reset to current widget quantity if invalid
      final validQuantity = widget.quantity > 0 ? widget.quantity : 1;
      _quantityController.text = validQuantity.toString();
      widget.onQuantityChanged(validQuantity);
      return;
    }
    final newQuantity = int.tryParse(text);
    if (newQuantity == null || newQuantity < 1) {
      // Reset to current widget quantity if invalid
      final validQuantity = widget.quantity > 0 ? widget.quantity : 1;
      _quantityController.text = validQuantity.toString();
      widget.onQuantityChanged(validQuantity);
      return;
    }
    widget.onQuantityChanged(newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    // Background color: slightly darker in light mode, slightly lighter in dark mode
    final backgroundColor = isDarkMode 
        ? Colors.grey[850]!
        : Colors.grey[100]!;
    
    // Responsive sizing: min for phone, max for laptop
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 800.0 : double.infinity;

    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => LayoutBuilder(
          builder: (context, constraints) {
            // Calculate height based on text size and screen width
            final itemHeight = _calculateItemHeight(textSize, screenWidth);
            
            return SizedBox(
              width: maxWidth == double.infinity ? double.infinity : maxWidth.clamp(280.0, maxWidth),
              height: itemHeight,
              child: Container(
                margin: const EdgeInsets.only(left: 14, right: 28, top: 8, bottom: 8), // Double right padding
                decoration: BoxDecoration(
                  color: backgroundColor,
                  // No border radius, no borders
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left section - Icon or Image (fixed width based on screen)
                    SizedBox(
                      width: screenWidth > 600 ? 100.0 : 80.0,
                      height: _calculateItemHeight(textSize, screenWidth),
                      child: Container(
                        color: backgroundColor,
                        child: ImageWithInfoIcon(
                          imagePath: widget.imagePath,
                          identifier: widget.name,
                          width: screenWidth > 600 ? 100.0 : 80.0,
                          height: _calculateItemHeight(textSize, screenWidth),
                          fit: BoxFit.cover,
                          fallbackIcon: Icon(
                            IconMappingService.getItemIcon(widget.name),
                            size: screenWidth > 600 ? 60 : 48,
                            color: widget.themeColor,
                          ),
                        ),
                      ),
                    ),
                    // Spacing between image and text
                    SizedBox(width: screenWidth > 600 ? 15.0 : 8.0),
                    // Middle section - Text information and controls
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth > 600 ? 14 : 8,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Name text - allow wrapping for long names
                              Text(
                                widget.name.isNotEmpty ? widget.name : 'Unknown Item',
                                style: TextStyleHelper.bodyBold(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              // Amount and Unit fields - responsive layout
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  // Use Column layout if width < 400px, otherwise use Row
                                  final useColumn = constraints.maxWidth < 400;

                                  if (useColumn) {
                                    // Stacked vertically
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Amount field
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Amount:',
                                                style: TextStyleHelper.small(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              child: TextField(
                                                controller: _quantityController,
                                                focusNode: _quantityFocusNode,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                                ],
                                                style: TextStyleHelper.body(),
                                                onSubmitted: (_) => _saveQuantity(),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.zero,
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        // Unit field
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'Unit:',
                                                style: TextStyleHelper.small(),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              child: TextField(
                                                controller: _unitController,
                                                style: TextStyleHelper.body(),
                                                onChanged: (value) {
                                                  ItemUnits.setUnit(widget.name, value);
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.zero,
                                                  ),
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  isDense: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  } else {
                                    // Side by side
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Amount field
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: screenWidth > 600 ? 60 : 50,
                                                child: Text(
                                                  'Amount:',
                                                  style: TextStyleHelper.small(),
                                                ),
                                              ),
                                              SizedBox(width: screenWidth > 600 ? 8 : 4),
                                              Flexible(
                                                child: SizedBox(
                                                  width: screenWidth > 600 ? 100 : 80,
                                                  child: TextField(
                                                    controller: _quantityController,
                                                    focusNode: _quantityFocusNode,
                                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                                    ],
                                                    style: TextStyleHelper.body(),
                                                    onSubmitted: (_) => _saveQuantity(),
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                      ),
                                                      contentPadding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth > 600 ? 8 : 4,
                                                        vertical: 2,
                                                      ),
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // Unit field
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: screenWidth > 600 ? 60 : 50,
                                                child: Text(
                                                  'Unit:',
                                                  style: TextStyleHelper.small(),
                                                ),
                                              ),
                                              SizedBox(width: screenWidth > 600 ? 8 : 4),
                                              Flexible(
                                                child: SizedBox(
                                                  width: screenWidth > 600 ? 100 : 80,
                                                  child: TextField(
                                                    controller: _unitController,
                                                    style: TextStyleHelper.body(),
                                                    onChanged: (value) {
                                                      ItemUnits.setUnit(widget.name, value);
                                                    },
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.zero,
                                                      ),
                                                      contentPadding: EdgeInsets.symmetric(
                                                        horizontal: screenWidth > 600 ? 8 : 4,
                                                        vertical: 2,
                                                      ),
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ]
                          ),
                      ),
                    ),
                    // Right section - Delete button (fixed size, no stretching)
                    SizedBox(
                      width: 48.0,
                      height: _calculateItemHeight(textSize, screenWidth),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 24.0, // Fixed size
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48.0,
                            maxWidth: 48.0,
                            minHeight: 48.0,
                            maxHeight: 48.0,
                          ),
                          onPressed: widget.onDelete,
                        ),
                      ),
                    ),
                  ]
                ),
              )
            );
          },
        ),
      ),
    );
  }
}
