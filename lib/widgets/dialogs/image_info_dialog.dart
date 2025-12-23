import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/text_style_helper.dart';
import '../../models/image_metadata.dart';

class ImageInfoDialog extends StatelessWidget {
  final ImageMetadata metadata;

  const ImageInfoDialog({
    super.key,
    required this.metadata,
  });

  static Future<void> show(BuildContext context, ImageMetadata metadata) async {
    await showDialog(
      context: context,
      builder: (context) => ImageInfoDialog(metadata: metadata),
    );
  }

  Future<void> _openImageUrl() async {
    final uri = Uri.parse(metadata.imageUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Image Information', style: TextStyleHelper.h4()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Image from Pexels', style: TextStyleHelper.bodyBold()),
          const SizedBox(height: 8),
          Text('Artist: ${metadata.artist}', style: TextStyleHelper.body()),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _openImageUrl,
            child: Text('View Image on Pexels', style: TextStyleHelper.body()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyleHelper.body()),
        ),
      ],
    );
  }
}

