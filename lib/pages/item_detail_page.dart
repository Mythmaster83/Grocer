import 'package:flutter/material.dart';
import '../utils/text_style_helper.dart';
import '../services/preferences_service.dart';
import '../services/icon_mapping_service.dart';
import '../utils/item_category_helper.dart';
import '../utils/item_calories_helper.dart';
import '../data/item_units.dart';
import '../widgets/image_with_info_icon.dart';
import '../services/image_service.dart';

class ItemDetailPage extends StatefulWidget {
  final String name;
  final int quantity;
  final bool bought;
  final Color themeColor;
  final String heroTag;
  final String? imagePath;

  const ItemDetailPage({
    super.key,
    required this.name,
    required this.quantity,
    required this.bought,
    required this.themeColor,
    required this.heroTag,
    this.imagePath,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String? _origin;

  @override
  void initState() {
    super.initState();
    _loadOrigin();
  }

  Future<void> _loadOrigin() async {
    final metadata = await ImageService.getImageMetadata(widget.name);
    if (metadata != null && metadata.artist.isNotEmpty) {
      setState(() {
        _origin = metadata.artist;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    // Background color: slightly darker in light mode, slightly lighter in dark mode
    final backgroundColor = isDarkMode 
        ? Colors.grey[850]!
        : Colors.grey[100]!;

    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<String>(
        valueListenable: PreferencesService.fontFamily,
        builder: (context, fontFamily, _) => ValueListenableBuilder<bool>(
          valueListenable: PreferencesService.isDarkMode,
          builder: (context, isDarkMode, _) => Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon or Image display
                    Hero(
                      tag: widget.heroTag,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        color: backgroundColor,
                        child: Center(
                          child: ImageWithInfoIcon(
                            imagePath: widget.imagePath,
                            identifier: widget.name,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            fallbackIcon: Icon(
                              IconMappingService.getItemIcon(widget.name),
                              size: 120,
                              color: widget.themeColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Colored divider (40px thick) - gradient matching theme color
                    Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            widget.themeColor,
                            widget.themeColor.withAlpha((0.7 * 255).round()),
                            widget.themeColor.withAlpha((0.5 * 255).round()),
                          ],
                        ),
                      ),
                    ),
                    // Item information - wrapped in light background container
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 300.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                ItemUnits.capitalizeFirst(widget.name),
                                style: TextStyleHelper.h2().copyWith(
                                  decoration: widget.bought 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              // Category
                              Text(
                                ItemCategoryHelper.getItemCategory(widget.name).toLowerCase(),
                                style: TextStyleHelper.bodyBold(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              // Amount
                              Text(
                                '${widget.quantity} ${ItemUnits.getPluralizedUnit(widget.name, widget.quantity)}',
                                style: TextStyleHelper.bodyBold(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              // Calories (only for food items)
                              if (ItemCategoryHelper.isFoodItem(ItemCategoryHelper.getItemCategory(widget.name)))
                                Text(
                                  ItemCaloriesHelper.getCaloriesDisplay(widget.name),
                                  style: TextStyleHelper.bodyBold(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (ItemCategoryHelper.isFoodItem(ItemCategoryHelper.getItemCategory(widget.name)))
                                const SizedBox(height: 5),
                              // Origin
                              if (_origin != null && _origin!.isNotEmpty)
                                Text(
                                  _origin!,
                                  style: TextStyleHelper.body(
                                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Back button
              Positioned(
                top: 8,
                left: 8,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha((0.9 * 255).round()),
                      foregroundColor: widget.themeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),),
        ),
      )
    );
  }
}
