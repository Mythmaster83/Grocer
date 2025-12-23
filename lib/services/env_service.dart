import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class EnvService {
  static final Map<String, String> _env = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    String? content;
    String? source;

    // 1. Try loading from assets first (works on all platforms including Android)
    try {
      if (kDebugMode) debugPrint('[EnvService] Attempting to load key.env from assets...');
      content = await rootBundle.loadString('assets/key.env');
      source = 'assets';
      if (kDebugMode) debugPrint('[EnvService] Successfully loaded key.env from assets');
    } catch (e) {
      if (kDebugMode) debugPrint('[EnvService] key.env not found in assets: $e');
    }

    // 2. If not in assets, try file system (for desktop development)
    if (content == null) {
      try {
        if (kDebugMode) debugPrint('[EnvService] Attempting to load key.env from file system...');
        final possiblePaths = <String>[];
        
        // Current directory (works in development)
        final currentDir = Directory.current.path;
        possiblePaths.add(path.join(currentDir, 'key.env'));
        
        // Try parent directories (in case we're in a subdirectory)
        var parentDir = Directory(currentDir).parent.path;
        for (int i = 0; i < 5; i++) {
          possiblePaths.add(path.join(parentDir, 'key.env'));
          parentDir = Directory(parentDir).parent.path;
        }
        
        // Try app documents directory (for physical devices)
        try {
          final appDocDir = await getApplicationDocumentsDirectory();
          possiblePaths.add(path.join(appDocDir.path, 'key.env'));
        } catch (e) {
          if (kDebugMode) debugPrint('[EnvService] Could not get app documents directory: $e');
        }
        
        // Try common project root locations
        if (Platform.isWindows) {
          final userDir = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '';
          if (userDir.isNotEmpty) {
            possiblePaths.add(path.join(userDir, 'AndroidStudioProjects', 'grocer_app', 'key.env'));
          }
        } else {
          final homeDir = Platform.environment['HOME'] ?? '';
          if (homeDir.isNotEmpty) {
            possiblePaths.add(path.join(homeDir, 'AndroidStudioProjects', 'grocer_app', 'key.env'));
          }
        }

        if (kDebugMode) debugPrint('[EnvService] Checking ${possiblePaths.length} file system locations...');
        
        for (final keyEnvPath in possiblePaths) {
          final file = File(keyEnvPath);
          if (await file.exists()) {
            content = await file.readAsString();
            source = keyEnvPath;
            if (kDebugMode) debugPrint('[EnvService] Found key.env at: $keyEnvPath');
            break;
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[EnvService] Error loading from file system: $e');
      }
    }

    // 3. Parse the content if we found it
    if (content != null && content.isNotEmpty) {
      if (kDebugMode) debugPrint('[EnvService] Successfully loaded key.env from: $source');
      if (kDebugMode) debugPrint('[EnvService] File content length: ${content.length}');
      
      final lines = content.split('\n');
      int loadedCount = 0;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
          final equalIndex = trimmed.indexOf('=');
          if (equalIndex > 0) {
            final key = trimmed.substring(0, equalIndex).trim();
            final value = trimmed.substring(equalIndex + 1).trim();
            _env[key] = value;
            loadedCount++;
            if (kDebugMode) debugPrint('[EnvService] Loaded key: $key (value length: ${value.length})');
          }
        }
      }
      if (kDebugMode) debugPrint('[EnvService] Loaded $loadedCount environment variables');
      _loaded = true;
    } else {
      if (kDebugMode) debugPrint('[EnvService] WARNING: key.env file not found in assets or file system');
      if (kDebugMode) debugPrint('[EnvService] To fix: Add key.env to assets/ directory and update pubspec.yaml');
      if (kReleaseMode) {
        print('[EnvService] Failed to load environment variables - key.env not found');
      }
    }
  }

  static String? get(String key) {
    final value = _env[key];
    if (value == null) {
      if (kDebugMode) debugPrint('[EnvService] Key "$key" not found in environment');
    } else {
      if (kDebugMode) debugPrint('[EnvService] Retrieved key "$key" (length: ${value.length})');
    }
    return value;
  }
}

