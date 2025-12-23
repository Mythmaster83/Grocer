import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/image_service.dart';
import 'dialogs/image_info_dialog.dart';

class ImageWithInfoIcon extends StatelessWidget {
  final String? imagePath;
  final String? fallbackAssetPath; // Asset path to use if imagePath is null/empty
  final String identifier; // Item name or list name
  final Widget fallbackIcon; // Icon to show if image is not available
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius; // Border radius to match parent container

  const ImageWithInfoIcon({
    super.key,
    required this.imagePath,
    this.fallbackAssetPath,
    required this.identifier,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  Future<void> _showImageInfo(BuildContext context) async {
    final metadata = await ImageService.getImageMetadata(identifier);
    if (metadata != null && context.mounted) {
      await ImageInfoDialog.show(context, metadata);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ImageWithInfoIcon] build called for identifier: "$identifier"');
    final bool hasImagePath = imagePath != null && imagePath!.isNotEmpty;
    final bool hasAssetFallback = fallbackAssetPath != null && fallbackAssetPath!.isNotEmpty;
    final bool hasImage = hasImagePath || hasAssetFallback;
    
    debugPrint('[ImageWithInfoIcon] hasImagePath: $hasImagePath, path: "$imagePath"');
    debugPrint('[ImageWithInfoIcon] hasAssetFallback: $hasAssetFallback, path: "$fallbackAssetPath"');
    
    Widget imageWidget;
    
    if (hasImagePath) {
      debugPrint('[ImageWithInfoIcon] Verifying image path: "$imagePath"');
      // Try to load from file path first - use FutureBuilder to verify file exists
      imageWidget = FutureBuilder<bool>(
        future: ImageService.verifyImagePath(imagePath),
        builder: (context, snapshot) {
          debugPrint('[ImageWithInfoIcon] FutureBuilder snapshot: hasData=${snapshot.hasData}, data=${snapshot.data}');
          if (snapshot.hasData && snapshot.data == true) {
            debugPrint('[ImageWithInfoIcon] Image path verified, loading Image.file');
            // File exists and is valid, try to load it
            return ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                child: Image.file(
                  File(imagePath!),
                  fit: fit,
                  width: width,
                  height: height,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('[ImageWithInfoIcon] Image.file error for "$imagePath": $error');
                    // Fall back to asset if available, otherwise use icon
                    if (hasAssetFallback) {
                      debugPrint('[ImageWithInfoIcon] Falling back to asset: $fallbackAssetPath');
                      return Image.asset(
                        fallbackAssetPath!,
                        fit: fit,
                        width: width,
                        height: height,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('[ImageWithInfoIcon] Asset also failed, using icon fallback');
                          // Only use icon if asset also fails
                          return _buildIconFallback();
                        },
                      );
                    }
                    debugPrint('[ImageWithInfoIcon] No asset fallback, using icon');
                    return _buildIconFallback();
                  },
                ),
              ),
            );
          } else {
            debugPrint('[ImageWithInfoIcon] Image path verification failed or pending');
            // File doesn't exist or is invalid, use fallback
            if (hasAssetFallback) {
              debugPrint('[ImageWithInfoIcon] Using asset fallback: $fallbackAssetPath');
              return ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                  child: Image.asset(
                    fallbackAssetPath!,
                    fit: fit,
                    width: width,
                    height: height,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('[ImageWithInfoIcon] Asset fallback failed, using icon');
                      return _buildIconFallback();
                    },
                  ),
                ),
              );
            }
            debugPrint('[ImageWithInfoIcon] No asset fallback available, using icon');
            return _buildIconFallback();
          }
        },
      );
    } else if (hasAssetFallback) {
      // Use asset fallback - prioritize asset over icon
      imageWidget = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: Image.asset(
            fallbackAssetPath!,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              // Only use icon if asset fails to load
              return _buildIconFallback();
            },
          ),
        ),
      );
    } else {
      // Use icon fallback only if no asset is provided
      imageWidget = _buildIconFallback();
    }
    
    // When height is null, wrap in Expanded or SizedBox.expand to fill parent
    if (height == null) {
      imageWidget = SizedBox.expand(child: imageWidget);
    } else {
      imageWidget = SizedBox(width: width, height: height, child: imageWidget);
    }
    
    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image or fallback - fills entire space
        imageWidget,
        // Info icon overlay (only show if we have an actual image, not just icon)
        if (hasImage)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _showImageInfo(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.6 * 255).round()),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconFallback() {
    // Center icon and fill available space
    return Center(child: fallbackIcon);
  }
}

