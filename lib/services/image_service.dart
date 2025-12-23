import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/image_metadata.dart';
import '../services/pexels_service.dart';

class ImageService {
  static Future<String> getImageDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    // Store images in a dedicated images directory
    final imageDir = Directory('${dir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir.path;
  }

  static Future<String> getMetadataDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    // Store metadata in a dedicated metadata directory
    final metadataDir = Directory('${dir.path}/metadata');
    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }
    return metadataDir.path;
  }

  static String _sanitizeFileName(String name) {
    // Remove invalid characters for file names
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(' ', '_');
  }

  static Future<String?> downloadAndSaveImage(
    String imageUrl,
    String identifier,
  ) async {
    if (kDebugMode) debugPrint('[ImageService] downloadAndSaveImage called for: "$identifier"');
    if (kDebugMode) debugPrint('[ImageService] Image URL: $imageUrl');
    try {
      // Add timeout for network requests (30 seconds)
      if (kDebugMode) debugPrint('[ImageService] Starting HTTP GET request...');
      final response = await http.get(
        Uri.parse(imageUrl),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) debugPrint('[ImageService] HTTP request timeout for "$identifier"');
          throw Exception('Image download timeout');
        },
      );
      
      if (kDebugMode) debugPrint('[ImageService] HTTP response status: ${response.statusCode}');
      if (kDebugMode) debugPrint('[ImageService] Response body size: ${response.bodyBytes.length} bytes');
      
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final imageDir = await getImageDirectory();
        if (kDebugMode) debugPrint('[ImageService] Image directory: $imageDir');
        final fileName = '${_sanitizeFileName(identifier)}.jpg';
        final filePath = path.join(imageDir, fileName);
        if (kDebugMode) debugPrint('[ImageService] Target file path: $filePath');
        final file = File(filePath);
        
        // Write image bytes
        if (kDebugMode) debugPrint('[ImageService] Writing ${response.bodyBytes.length} bytes to file...');
        await file.writeAsBytes(response.bodyBytes);
        
        // Verify file was written successfully
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;
        if (kDebugMode) debugPrint('[ImageService] File exists: $exists, size: $length bytes');
        
        if (exists && length > 0) {
          if (kDebugMode) debugPrint('[ImageService] Image successfully saved to: $filePath');
          if (kDebugMode) debugPrint('[ImageService] File verification PASSED - exists: $exists, length: $length bytes');
          if (kDebugMode) debugPrint('[ImageService] Returning filePath: "$filePath"');
          return filePath;
        } else {
          if (kDebugMode) debugPrint('[ImageService] File verification FAILED - exists: $exists, length: $length');
        }
      } else {
        if (kDebugMode) debugPrint('[ImageService] Invalid response - status: ${response.statusCode}, body empty: ${response.bodyBytes.isEmpty}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageService] Exception in downloadAndSaveImage for "$identifier": $e');
    }
    return null;
  }

  /// Check if image fetch was already attempted and failed
  static Future<bool> _wasImageNotFound(String identifier) async {
    try {
      if (kDebugMode) debugPrint('[ImageService] Checking if image was not found for: "$identifier"');
      final metadata = await ImageMetadata.loadMetadata(identifier);
      if (metadata != null) {
        if (kDebugMode) debugPrint('[ImageService] Metadata found for "$identifier", imagePath: "${metadata.imagePath}"');
        // If metadata exists but imagePath is empty or null, it means we tried and failed
        if (metadata.imagePath.isEmpty || !await imageExists(metadata.imagePath)) {
          if (kDebugMode) debugPrint('[ImageService] Image was previously not found for "$identifier"');
          return true;
        } else {
          if (kDebugMode) debugPrint('[ImageService] Image exists for "$identifier"');
        }
      } else {
        if (kDebugMode) debugPrint('[ImageService] No metadata found for "$identifier"');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageService] Error checking metadata for "$identifier": $e');
      // If we can't check, assume we haven't tried
    }
    return false;
  }

  static Future<String?> fetchAndSaveImageForItem(String itemName) async {
    if (kDebugMode) debugPrint('[ImageService] fetchAndSaveImageForItem called for: "$itemName"');
    
    // Check if API key is available - if not, skip entirely
    final apiKey = PexelsService.apiKey;
    if (apiKey == null) {
      if (kDebugMode) debugPrint('[ImageService] API key not available, skipping fetch for "$itemName"');
      return null;
    }
    if (kDebugMode) debugPrint('[ImageService] API key is available, proceeding with fetch for "$itemName"');
    
    // Check if we already tried and failed
    final wasNotFound = await _wasImageNotFound(itemName);
    if (wasNotFound) {
      if (kDebugMode) debugPrint('[ImageService] Image was previously not found for "$itemName"');
      // If API key is now available but it wasn't before, allow retry
      // Check if the "not found" was due to missing API key by checking if metadata has empty fields
      final metadata = await ImageMetadata.loadMetadata(itemName);
      if (metadata != null && metadata.imagePath.isEmpty && metadata.imageUrl.isEmpty) {
        if (kDebugMode) debugPrint('[ImageService] Previous "not found" likely due to missing API key. Retrying now that API key is available.');
        // Delete the old metadata to allow retry
        try {
          final metadataDir = await ImageMetadata.getMetadataDirectory();
          final file = File('$metadataDir/$itemName.json');
          if (await file.exists()) {
            await file.delete();
            if (kDebugMode) debugPrint('[ImageService] Deleted old "not found" metadata for "$itemName" to allow retry');
            // Continue with the fetch below
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[ImageService] Error deleting old metadata: $e');
          // Continue anyway
        }
      } else {
        if (kDebugMode) debugPrint('[ImageService] Skipping fetch - image was genuinely not found');
        return null;
      }
    }

    // Proceed with image fetch
    if (kDebugMode) debugPrint('[ImageService] Proceeding with image fetch for "$itemName"');

    try {
      if (kDebugMode) debugPrint('[ImageService] Searching Pexels for: "$itemName"');
      // Search for image
      final photo = await PexelsService.searchFirstPhoto(itemName);
      if (photo == null) {
        if (kDebugMode) debugPrint('[ImageService] No photo found in Pexels for "$itemName"');
        // Save metadata to mark as "not found" so we don't retry
        final notFoundMetadata = ImageMetadata(
          imagePath: '',
          artist: '',
          imageUrl: '',
        );
        await ImageMetadata.saveMetadata(itemName, notFoundMetadata);
        if (kDebugMode) debugPrint('[ImageService] Saved "not found" metadata for "$itemName"');
        return null;
      }

      if (kDebugMode) debugPrint('[ImageService] Photo found for "$itemName", URL: ${photo.srcMedium}');
      if (kDebugMode) debugPrint('[ImageService] Downloading image from: ${photo.srcMedium}');
      // Download and save image
      final imagePath = await downloadAndSaveImage(
        photo.srcMedium,
        itemName,
      );

      if (kDebugMode) debugPrint('[ImageService] downloadAndSaveImage returned: ${imagePath != null ? "SUCCESS - $imagePath" : "NULL"}');
      
      if (imagePath != null) {
        if (kDebugMode) debugPrint('[ImageService] Image downloaded and saved to: "$imagePath"');
        // Verify file exists
        final file = File(imagePath);
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;
        if (kDebugMode) debugPrint('[ImageService] Verifying saved file - exists: $exists, size: $length bytes');
        
        // Save metadata
        final metadata = ImageMetadata(
          imagePath: imagePath,
          artist: photo.photographer,
          imageUrl: photo.srcOriginal,
          photographerUrl: photo.photographerUrl.isNotEmpty
              ? photo.photographerUrl
              : null,
        );
        await ImageMetadata.saveMetadata(itemName, metadata);
        if (kDebugMode) debugPrint('[ImageService] Metadata saved for "$itemName" with imagePath: "$imagePath"');
        
        // Verify metadata was saved correctly
        final savedMetadata = await ImageMetadata.loadMetadata(itemName);
        if (kDebugMode) debugPrint('[ImageService] Verification - loaded metadata imagePath: "${savedMetadata?.imagePath ?? "null"}"');
      } else {
        if (kDebugMode) debugPrint('[ImageService] Failed to download/save image for "$itemName"');
      }

      return imagePath;
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageService] Exception in fetchAndSaveImageForItem for "$itemName": $e');
      return null;
    }
  }

  static Future<String?> fetchAndSaveImageForList(String listName) async {
    if (kDebugMode) debugPrint('[ImageService] fetchAndSaveImageForList called for: "$listName"');
    
    // Validate list name
    if (listName.isEmpty || listName.trim().isEmpty) {
      if (kDebugMode) debugPrint('[ImageService] Invalid list name, skipping fetch');
      return null;
    }
    
    // Check if API key is available - if not, skip entirely
    final apiKey = PexelsService.apiKey;
    if (apiKey == null) {
      if (kDebugMode) debugPrint('[ImageService] API key not available, skipping fetch for list "$listName"');
      return null;
    }
    if (kDebugMode) debugPrint('[ImageService] API key is available, proceeding with fetch for list "$listName"');
    
    // Check if we already tried and failed
    final wasNotFound = await _wasImageNotFound(listName);
    if (wasNotFound) {
      if (kDebugMode) debugPrint('[ImageService] Image was previously not found for list "$listName"');
      // If API key is now available but it wasn't before, allow retry
      final metadata = await ImageMetadata.loadMetadata(listName);
      if (metadata != null && metadata.imagePath.isEmpty && metadata.imageUrl.isEmpty) {
        if (kDebugMode) debugPrint('[ImageService] Previous "not found" likely due to missing API key. Retrying now that API key is available.');
        // Delete the old metadata to allow retry
        try {
          final metadataDir = await ImageMetadata.getMetadataDirectory();
          final file = File('$metadataDir/$listName.json');
          if (await file.exists()) {
            await file.delete();
            if (kDebugMode) debugPrint('[ImageService] Deleted old "not found" metadata for list "$listName" to allow retry');
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[ImageService] Error deleting old metadata: $e');
        }
      } else {
        if (kDebugMode) debugPrint('[ImageService] Skipping fetch - image was genuinely not found for list "$listName"');
        return null;
      }
    }

    // Proceed with image fetch
    if (kDebugMode) debugPrint('[ImageService] Proceeding with image fetch for list "$listName"');
    try {
      // Search for image using list name
      final photo = await PexelsService.searchFirstPhoto(listName);
      if (photo == null) {
        // Save metadata to mark as "not found" so we don't retry
        final notFoundMetadata = ImageMetadata(
          imagePath: '',
          artist: '',
          imageUrl: '',
        );
        await ImageMetadata.saveMetadata(listName, notFoundMetadata);
        return null;
      }

      if (kDebugMode) debugPrint('[ImageService] Photo found for list "$listName", URL: ${photo.srcMedium}');
      if (kDebugMode) debugPrint('[ImageService] Downloading image from: ${photo.srcMedium}');
      // Download and save image
      final imagePath = await downloadAndSaveImage(
        photo.srcMedium,
        listName,
      );

      if (kDebugMode) debugPrint('[ImageService] downloadAndSaveImage returned for list: ${imagePath != null ? "SUCCESS - $imagePath" : "NULL"}');
      
      if (imagePath != null) {
        if (kDebugMode) debugPrint('[ImageService] Image downloaded and saved to: "$imagePath"');
        // Verify file exists
        final file = File(imagePath);
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;
        if (kDebugMode) debugPrint('[ImageService] Verifying saved file for list - exists: $exists, size: $length bytes');
        
        // Save metadata
        final metadata = ImageMetadata(
          imagePath: imagePath,
          artist: photo.photographer,
          imageUrl: photo.srcOriginal,
          photographerUrl: photo.photographerUrl.isNotEmpty
              ? photo.photographerUrl
              : null,
        );
        await ImageMetadata.saveMetadata(listName, metadata);
        if (kDebugMode) debugPrint('[ImageService] Metadata saved for list "$listName" with imagePath: "$imagePath"');
        
        // Verify metadata was saved correctly
        final savedMetadata = await ImageMetadata.loadMetadata(listName);
        if (kDebugMode) debugPrint('[ImageService] Verification - loaded metadata imagePath for list: "${savedMetadata?.imagePath ?? "null"}"');
      } else {
        if (kDebugMode) debugPrint('[ImageService] Failed to download/save image for list "$listName"');
      }

      return imagePath;
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageService] Exception in fetchAndSaveImageForList for "$listName": $e');
      return null;
    }
  }

  static Future<ImageMetadata?> getImageMetadata(String identifier) async {
    if (kDebugMode) debugPrint('[ImageService] getImageMetadata called for: "$identifier"');
    final metadata = await ImageMetadata.loadMetadata(identifier);
    if (kDebugMode) debugPrint('[ImageService] getImageMetadata result: ${metadata != null ? "found" : "not found"}');
    if (metadata != null) {
      if (kDebugMode) debugPrint('[ImageService] Metadata imagePath: "${metadata.imagePath}"');
    }
    return metadata;
  }

  static Future<bool> imageExists(String imagePath) async {
    if (imagePath.isEmpty) {
      if (kDebugMode) debugPrint('[ImageService] imageExists: path is empty');
      return false;
    }
    try {
      if (kDebugMode) debugPrint('[ImageService] Checking if image exists: "$imagePath"');
      final file = File(imagePath);
      final exists = await file.exists();
      if (kDebugMode) debugPrint('[ImageService] File exists: $exists');
      if (exists) {
        // Verify file is not empty
        final length = await file.length();
        if (kDebugMode) debugPrint('[ImageService] File size: $length bytes');
        return length > 0;
      }
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('[ImageService] Error checking image existence: $e');
      return false;
    }
  }
  
  /// Verify that an image path is valid and the file can be read
  static Future<bool> verifyImagePath(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }
    return await imageExists(imagePath);
  }
}

