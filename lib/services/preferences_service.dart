import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyThemeColor = 'theme_color';
  static const String _keyTextSize = 'text_size';
  static const String _keyPageOrder = 'page_order';
  static const String _keyFontFamily = 'font_family';

  // Default font family
  static const String defaultFontFamily = 'Poppins';

  // Notifiers
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);
  static final ValueNotifier<Color> themeColor = ValueNotifier(Colors.blue);
  static final ValueNotifier<double> textSize = ValueNotifier(16.0);
  static final ValueNotifier<String> fontFamily = ValueNotifier(defaultFontFamily);
  static final ValueNotifier<List<String>> pageOrder =
      ValueNotifier(['home', 'stock', 'lists']); // Settings removed - accessed via menu

  // Load all preferences
  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if dark mode preference exists, if not use system setting
    final savedDarkMode = prefs.getBool(_keyDarkMode);
    if (savedDarkMode == null) {
      // Use system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      isDarkMode.value = brightness == Brightness.dark;
    } else {
      isDarkMode.value = savedDarkMode;
    }
    
    final colorValue = prefs.getInt(_keyThemeColor);
    if (colorValue != null) {
      themeColor.value = Color(colorValue);
    }

    // Check if text size preference exists, if not use system text scale
    final savedTextSize = prefs.getDouble(_keyTextSize);
    if (savedTextSize == null) {
      // Use system text scale factor (default to 1.0 if not available)
      final textScaleFactor = WidgetsBinding.instance.platformDispatcher.textScaleFactor;
      // Convert scale factor to approximate font size (scale factor 1.0 = 16.0)
      textSize.value = 16.0 * textScaleFactor;
    } else {
      textSize.value = savedTextSize;
    }

    final pageOrderList = prefs.getStringList(_keyPageOrder);
    if (pageOrderList != null && pageOrderList.isNotEmpty) {
      // Filter out 'settings' from page order (settings is accessed via menu)
      final filteredOrder = pageOrderList.where((page) => page != 'settings').toList();
      if (filteredOrder.isNotEmpty) {
        pageOrder.value = filteredOrder;
      }
    }

    final savedFontFamily = prefs.getString(_keyFontFamily);
    if (savedFontFamily != null && savedFontFamily.isNotEmpty) {
      fontFamily.value = savedFontFamily;
    } else {
      fontFamily.value = defaultFontFamily;
    }
  }

  // Save dark mode
  static Future<void> saveDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // Save theme color
  static Future<void> saveThemeColor(Color color) async {
    themeColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeColor, color.toARGB32());
  }

  // Save text size
  static Future<void> saveTextSize(double size) async {
    textSize.value = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextSize, size);
  }

  // Save page order
  static Future<void> savePageOrder(List<String> order) async {
    pageOrder.value = order;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPageOrder, order);
  }

  // Save font family
  static Future<void> saveFontFamily(String family) async {
    fontFamily.value = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontFamily, family);
  }
}

