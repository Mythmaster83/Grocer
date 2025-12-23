import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ImageMetadata {
  final String imagePath;
  final String artist;
  final String imageUrl;
  final String? photographerUrl;

  ImageMetadata({
    required this.imagePath,
    required this.artist,
    required this.imageUrl,
    this.photographerUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'artist': artist,
      'imageUrl': imageUrl,
      'photographerUrl': photographerUrl,
    };
  }

  factory ImageMetadata.fromJson(Map<String, dynamic> json) {
    return ImageMetadata(
      imagePath: json['imagePath'] as String,
      artist: json['artist'] as String,
      imageUrl: json['imageUrl'] as String,
      photographerUrl: json['photographerUrl'] as String?,
    );
  }

  static Future<String> getMetadataDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    // Store metadata in a dedicated metadata directory (matching images structure)
    final metadataDir = Directory('${dir.path}/metadata');
    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }
    return metadataDir.path;
  }

  static Future<void> saveMetadata(String identifier, ImageMetadata metadata) async {
    if (kDebugMode) debugPrint('[ImageMetadata] saveMetadata called for: "$identifier"');
    try {
      final metadataDir = await getMetadataDirectory();
      if (kDebugMode) debugPrint('[ImageMetadata] Metadata directory: $metadataDir');
      final file = File('$metadataDir/$identifier.json');
      if (kDebugMode) debugPrint('[ImageMetadata] Saving to file: ${file.path}');
      if (kDebugMode) debugPrint('[ImageMetadata] Metadata imagePath: "${metadata.imagePath}"');
      await file.writeAsString(jsonEncode(metadata.toJson()));
      if (kDebugMode) debugPrint('[ImageMetadata] Metadata saved successfully for "$identifier"');
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageMetadata] Error saving metadata for "$identifier": $e');
    }
  }

  static Future<ImageMetadata?> loadMetadata(String identifier) async {
    if (kDebugMode) debugPrint('[ImageMetadata] loadMetadata called for: "$identifier"');
    try {
      final metadataDir = await getMetadataDirectory();
      if (kDebugMode) debugPrint('[ImageMetadata] Metadata directory: $metadataDir');
      final file = File('$metadataDir/$identifier.json');
      if (kDebugMode) debugPrint('[ImageMetadata] Loading from file: ${file.path}');
      final exists = await file.exists();
      if (kDebugMode) debugPrint('[ImageMetadata] File exists: $exists');
      if (exists) {
        final content = await file.readAsString();
        if (kDebugMode) debugPrint('[ImageMetadata] File content length: ${content.length}');
        final json = jsonDecode(content) as Map<String, dynamic>;
        final metadata = ImageMetadata.fromJson(json);
        if (kDebugMode) debugPrint('[ImageMetadata] Loaded metadata for "$identifier", imagePath: "${metadata.imagePath}"');
        return metadata;
      } else {
        if (kDebugMode) debugPrint('[ImageMetadata] Metadata file does not exist for "$identifier"');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageMetadata] Error loading metadata for "$identifier": $e');
      // Metadata file doesn't exist or is invalid
    }
    return null;
  }
}

