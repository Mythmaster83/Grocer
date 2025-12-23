import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

/// Helper class for creating consistent text styles with proper ratios
class TextStyleHelper {
  // Standard text size ratios
  static const double _h1Ratio = 2.0;      // 2x base size
  static const double _h2Ratio = 1.75;     // 1.75x base size
  static const double _h3Ratio = 1.5;      // 1.5x base size
  static const double _h4Ratio = 1.25;     // 1.25x base size
  static const double _bodyRatio = 1.0;    // 1x base size (normal)
  static const double _smallRatio = 0.875; // 0.875x base size
  static const double _tinyRatio = 0.75;   // 0.75x base size

  static double get baseSize => PreferencesService.textSize.value;
  static String get fontFamily => PreferencesService.fontFamily.value;
  
  // Helper to get font family, but exclude Material Icons font
  static String? _getTextFontFamily(String? fontFamily) {
    // Never apply custom fonts to Material Icons
    // Material Icons use their own font family which is handled automatically
    return fontFamily;
  }

  // Headings
  static TextStyle h1({Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _h1Ratio,
      fontWeight: weight ?? FontWeight.bold,
      color: color,
    );
  }

  static TextStyle h2({Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _h2Ratio,
      fontWeight: weight ?? FontWeight.bold,
      color: color,
    );
  }

  static TextStyle h3({Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _h3Ratio,
      fontWeight: weight ?? FontWeight.w600,
      color: color,
    );
  }

  static TextStyle h4({Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _h4Ratio,
      fontWeight: weight ?? FontWeight.w600,
      color: color,
    );
  }

  // Body text
  static TextStyle body({Color? color, FontWeight? weight, TextDecoration? decoration}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _bodyRatio,
      fontWeight: weight ?? FontWeight.normal,
      color: color,
      decoration: decoration,
    );
  }

  static TextStyle bodyBold({Color? color}) {
    return body(color: color, weight: FontWeight.bold);
  }

  // Small text
  static TextStyle small({Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _smallRatio,
      fontWeight: weight ?? FontWeight.normal,
      color: color,
    );
  }

  // Tiny text
  static TextStyle tiny({Color? color}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * _tinyRatio,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  // Custom size with ratio
  static TextStyle custom(double ratio, {Color? color, FontWeight? weight}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: baseSize * ratio,
      fontWeight: weight ?? FontWeight.normal,
      color: color,
    );
  }
}

