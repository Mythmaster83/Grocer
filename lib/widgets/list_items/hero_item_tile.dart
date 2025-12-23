import 'package:flutter/material.dart';
import '../../utils/text_style_helper.dart';
import '../../services/preferences_service.dart';
import '../../services/icon_mapping_service.dart';
import '../../data/item_units.dart';
import '../../pages/item_detail_page.dart';
import '../../widgets/image_with_info_icon.dart';
import '../../services/image_service.dart';
import '../../services/database_service.dart';
import '../../utils/item_category_helper.dart';
import '../../utils/item_calories_helper.dart';

class HeroItemTile extends StatefulWidget {
  final String name;
  final bool bought;
  final int quantity;
  final Function(bool?)? onCheckboxChanged;
  final Color themeColor;
  final bool showCheckbox;
  final String heroTag;
  final String? imagePath;

  const HeroItemTile({
    super.key,
    required this.name,
    required this.bought,
    required this.quantity,
    this.onCheckboxChanged,
    required this.themeColor,
    this.showCheckbox = true,
    required this.heroTag,
    this.imagePath,
  });

  @override
  State<HeroItemTile> createState() => _HeroItemTileState();
}

class _HeroItemTileState extends State<HeroItemTile> {
  String? _currentImagePath;

  // Calculate tile height based on screen width
  double _calculateHeight(double screenWidth, textSize) {
    final maxHeight = (textSize * 6) + 50;
    return maxHeight;
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[HeroItemTile] initState called for item: "${widget.name}"');
    debugPrint(
      '[HeroItemTile] Initial imagePath from widget: "${widget.imagePath}"',
    );
    _currentImagePath = widget.imagePath;
    // Trigger image fetch if item doesn't have an image
    if (_currentImagePath == null || _currentImagePath!.isEmpty) {
      debugPrint(
        '[HeroItemTile] No image path, triggering fetch for: "${widget.name}"',
      );
      _fetchImageIfNeeded();
    } else {
      debugPrint(
        '[HeroItemTile] Image path already exists: "$_currentImagePath", skipping fetch',
      );
    }
  }

  @override
  void didUpdateWidget(covariant HeroItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _currentImagePath = widget.imagePath;
    }
  }

  void _fetchImageIfNeeded() async {
    debugPrint(
      '[HeroItemTile] _fetchImageIfNeeded called for item: "${widget.name}"',
    );
    debugPrint('[HeroItemTile] Current imagePath: ${widget.imagePath}');

    // Check if we already tried and failed
    final metadata = await ImageService.getImageMetadata(widget.name);
    debugPrint(
      '[HeroItemTile] Metadata lookup result: ${metadata != null ? "found" : "not found"}',
    );
    if (metadata != null) {
      debugPrint('[HeroItemTile] Metadata imagePath: "${metadata.imagePath}"');
      if (metadata.imagePath.isEmpty ||
          !await ImageService.imageExists(metadata.imagePath)) {
        debugPrint(
          '[HeroItemTile] Image not found or doesn\'t exist, skipping fetch',
        );
        return;
      } else {
        debugPrint(
          '[HeroItemTile] Image exists at path: "${metadata.imagePath}"',
        );
      }
    }

    debugPrint('[HeroItemTile] Starting image fetch for: "${widget.name}"');
    // Fetch image asynchronously - this will update the database automatically
    ImageService.fetchAndSaveImageForItem(widget.name)
        .then((imagePath) async {
          debugPrint(
            '[HeroItemTile] Image fetch completed for "${widget.name}", result: ${imagePath != null ? "success" : "failed"}',
          );
          if (imagePath != null) {
            debugPrint('[HeroItemTile] Image saved at path: "$imagePath"');
            if (mounted) {
              // Find and update all items with this name across all lists
              final allLists = await DatabaseService.getShoppingLists();
              debugPrint(
                '[HeroItemTile] Updating ${allLists.length} shopping lists',
              );
              for (final list in allLists) {
                final items = await DatabaseService.getListItems(
                  list.name,
                  false,
                );
                for (final item in items) {
                  if (item.name == widget.name &&
                      (item.imagePath == null || item.imagePath!.isEmpty)) {
                    debugPrint(
                      '[HeroItemTile] Updating item "${item.name}" in list "${list.name}" with image path',
                    );
                    item.imagePath = imagePath;
                    await DatabaseService.updateListItem(item);
                  }
                }
              }
              final stockLists = await DatabaseService.getStockLists();
              debugPrint(
                '[HeroItemTile] Updating ${stockLists.length} stock lists',
              );
              for (final list in stockLists) {
                final items = await DatabaseService.getListItems(
                  list.name,
                  true,
                );
                for (final item in items) {
                  if (item.name == widget.name &&
                      (item.imagePath == null || item.imagePath!.isEmpty)) {
                    debugPrint(
                      '[HeroItemTile] Updating item "${item.name}" in stock list "${list.name}" with image path',
                    );
                    item.imagePath = imagePath;
                    await DatabaseService.updateListItem(item);
                  }
                }
              }
              if (mounted) {
                setState(() {
                  _currentImagePath = imagePath;
                  debugPrint(
                    '[HeroItemTile] Updated _currentImagePath to: "$imagePath"',
                  );
                });
              }
            }
          } else {
            debugPrint(
              '[HeroItemTile] Image fetch returned null for "${widget.name}"',
            );
          }
        })
        .catchError((error) {
          debugPrint(
            '[HeroItemTile] Error fetching image for "${widget.name}": $error',
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    // Background color: slightly darker in light mode, slightly lighter in dark mode
    final backgroundColor = isDarkMode ? Colors.grey[850]! : Colors.grey[100]!;

    // Responsive sizing: min for phone, max for laptop
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 600 ? 800.0 : double.infinity;
    final iconWidth = screenWidth > 600 ? 100.0 : 80.0;


    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) {
          // Calculate fixed height for the tile
          final tileHeight = _calculateHeight(screenWidth, textSize);
          return SizedBox(
            width: maxWidth == double.infinity ? double.infinity : maxWidth.clamp(280.0, maxWidth),
            height: tileHeight,
            child: Container(
              margin: const EdgeInsets.only(
                left: 14,
                right: 28,
                top: 8,
                bottom: 8,
              ), // Double right padding
              decoration: BoxDecoration(
                color: backgroundColor,
                // No border radius, no borders
              ),
              child: Hero(
                tag: widget.heroTag,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(
                            name: widget.name,
                            quantity: widget.quantity,
                            bought: widget.bought,
                            themeColor: widget.themeColor,
                            heroTag: widget.heroTag,
                            imagePath: widget.imagePath,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: tileHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left section - Icon or Image (1.5x wider in normal view)
                          SizedBox(
                            width: iconWidth * 1.5,
                            height: tileHeight,
                            child: Container(
                              color: backgroundColor,
                              child: ImageWithInfoIcon(
                                imagePath: _currentImagePath,
                                identifier: widget.name,
                                width: iconWidth * 1.5,
                                height: tileHeight,
                                fit: BoxFit.cover,
                                fallbackIcon: Icon(
                                  IconMappingService.getItemIcon(widget.name),
                                  size: screenWidth > 600 ? 56 : 48,
                                  color: widget.themeColor,
                                ),
                              ),
                            ),
                          ),
                          // Spacing between image and text (15px for item tiles)
                          const SizedBox(width: 15.0),
                          // Middle section - Text information
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 14,
                                top: 10,
                                bottom: 14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name - 10px below top
                                  Text(
                                    widget.name,
                                    style: TextStyleHelper.bodyBold()
                                        .copyWith(
                                          decoration: widget.bought
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ), // 5px below title
                                  // Category (e.g., "fruit")
                                  Text(
                                    ItemCategoryHelper.getItemCategory(
                                      widget.name,
                                    ).toLowerCase(),
                                    style: TextStyleHelper.small(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ), // 5px below category
                                  // Amount with unit (e.g., "5 lbs" or "5 apples")
                                  Text(
                                    '${widget.quantity} ${ItemUnits.getPluralizedUnit(widget.name, widget.quantity)}',
                                    style: TextStyleHelper.small(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ), // 5px below amount
                                  // Calories (only for food items)
                                  if (ItemCategoryHelper.isFoodItem(
                                    ItemCategoryHelper.getItemCategory(
                                      widget.name,
                                    ),
                                  ))
                                    Text(
                                      ItemCaloriesHelper.getCaloriesDisplay(
                                        widget.name,
                                      ),
                                      style: TextStyleHelper.small(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Right section - Checkbox (fixed size, closer to right edge)
                          if (widget.showCheckbox)
                            SizedBox(
                              width: 48.0,
                              height: tileHeight,
                              child: Center(
                                child: Checkbox(
                                  value: widget.bought,
                                  onChanged: widget.onCheckboxChanged,
                                  activeColor: widget.themeColor,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
