import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'env_service.dart';

class PexelsPhoto {
  final int id;
  final String photographer;
  final String photographerUrl;
  final String srcMedium; // Medium size image URL
  final String srcOriginal; // Original image URL

  PexelsPhoto({
    required this.id,
    required this.photographer,
    required this.photographerUrl,
    required this.srcMedium,
    required this.srcOriginal,
  });

  factory PexelsPhoto.fromJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>;
    return PexelsPhoto(
      id: json['id'] as int,
      photographer: json['photographer'] as String,
      photographerUrl: json['photographer_url'] as String? ?? '',
      srcMedium: src['medium'] as String,
      srcOriginal: src['original'] as String,
    );
  }
}

class PexelsService {
  static String? get apiKey {
    final key = EnvService.get('PEXELS_API_KEY');
    if (kDebugMode) debugPrint('[PexelsService] apiKey getter called, key found: ${key != null}, length: ${key?.length ?? 0}');
    if (key != null && key.isNotEmpty && key != 'your_pexels_api_key_here') {
      if (kDebugMode) debugPrint('[PexelsService] Valid API key found');
      return key;
    }
    if (kDebugMode) debugPrint('[PexelsService] No valid API key found');
    return null;
  }

  static Future<List<PexelsPhoto>> searchPhotos(String query, {int perPage = 1}) async {
    if (kDebugMode) debugPrint('[PexelsService] searchPhotos called with query: "$query", perPage: $perPage');
    final apiKey = PexelsService.apiKey;
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_pexels_api_key_here') {
      if (kDebugMode) debugPrint('[PexelsService] ERROR: API key not configured');
      throw Exception('Pexels API key not configured. Please set PEXELS_API_KEY in key.env file.');
    }
    if (kDebugMode) debugPrint('[PexelsService] API key found (length: ${apiKey.length})');

    try {
      // Convert query to lowercase for consistent searching
      final lowercaseQuery = query.toLowerCase();
      final encodedQuery = Uri.encodeComponent(lowercaseQuery);
      final url = Uri.parse(
        'https://api.pexels.com/v1/search?query=$encodedQuery&per_page=$perPage',
      );
      if (kDebugMode) debugPrint('[PexelsService] Search URL: $url');

      if (kDebugMode) debugPrint('[PexelsService] Sending HTTP GET request...');
      final response = await http.get(
        url,
        headers: {
          'Authorization': apiKey,
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) debugPrint('[PexelsService] Request timeout');
          throw Exception('Pexels API request timeout');
        },
      );

      if (kDebugMode) debugPrint('[PexelsService] Response status code: ${response.statusCode}');
      if (kDebugMode) debugPrint('[PexelsService] Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final photos = data['photos'] as List<dynamic>;
        if (kDebugMode) debugPrint('[PexelsService] Found ${photos.length} photos');
        final photoList = photos.map((photo) => PexelsPhoto.fromJson(photo as Map<String, dynamic>)).toList();
        if (photoList.isNotEmpty) {
          if (kDebugMode) debugPrint('[PexelsService] First photo URL: ${photoList.first.srcMedium}');
        }
        return photoList;
      } else if (response.statusCode == 401) {
        if (kDebugMode) debugPrint('[PexelsService] ERROR: Invalid API key (401)');
        throw Exception('Invalid Pexels API key. Please check your key.env file.');
      } else {
        if (kDebugMode) debugPrint('[PexelsService] ERROR: API returned status ${response.statusCode}');
        throw Exception('Pexels API error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[PexelsService] Exception in searchPhotos: $e');
      if (e is Exception) rethrow;
      throw Exception('Failed to search Pexels: $e');
    }
  }

  static Future<PexelsPhoto?> searchFirstPhoto(String query) async {
    if (kDebugMode) debugPrint('[PexelsService] searchFirstPhoto called with query: "$query"');
    if (kDebugMode) debugPrint('[PexelsService] Checking API key before search...');
    final key = apiKey;
    if (kDebugMode) debugPrint('[PexelsService] API key check result: ${key != null ? "FOUND (length: ${key.length})" : "NOT FOUND"}');
    
    try {
      if (kDebugMode) debugPrint('[PexelsService] Calling searchPhotos...');
      final photos = await searchPhotos(query, perPage: 1);
      if (kDebugMode) debugPrint('[PexelsService] searchPhotos returned ${photos.length} photos');
      if (photos.isEmpty) {
        if (kDebugMode) debugPrint('[PexelsService] No photos found for query: "$query"');
        return null;
      }
      final firstPhoto = photos.first;
      if (kDebugMode) debugPrint('[PexelsService] Returning first photo for query: "$query"');
      if (kDebugMode) debugPrint('[PexelsService] Photo details - ID: ${firstPhoto.id}, Photographer: ${firstPhoto.photographer}, URL: ${firstPhoto.srcMedium}');
      return firstPhoto;
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('[PexelsService] Exception in searchFirstPhoto for "$query": $e');
      if (kDebugMode) debugPrint('[PexelsService] Stack trace: $stackTrace');
      return null;
    }
  }
}

