import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/text_style_helper.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<double> onTextSizeChanged;
  final ValueChanged<String>? onFontFamilyChanged;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.onColorSelected,
    required this.onTextSizeChanged,
    this.onFontFamilyChanged,
  });

  static const List<Color> paletteOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  static const List<double> textSizeOptions = [14, 16, 18, 20, 22];
  
  // System fonts and available fonts
  static const List<String> fontFamilyOptions = [
    'Poppins',        // Available in fonts folder
    'Roboto',         // System font (Android)
    'SF Pro Display', // System font (iOS)
    'Segoe UI',       // System font (Windows)
    'Arial',          // System font (cross-platform)
    'Helvetica',      // System font (cross-platform)
    'Times New Roman', // System font (cross-platform)
    'Courier New',    // System font (cross-platform)
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) {
        return ValueListenableBuilder<String>(
          valueListenable: PreferencesService.fontFamily,
          builder: (context, fontFamily, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: PreferencesService.themeColor,
          builder: (context, themeColor, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: PreferencesService.isDarkMode,
              builder: (context, isDarkMode, _) {
                return Scaffold(
                  appBar: AppBar(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    centerTitle: true,
                  ),
                  body: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyleHelper.h4(),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          isDarkMode ? 'Dark Mode On' : 'Dark Mode Off',
                          style: TextStyleHelper.body(),
                        ),
                        value: isDarkMode,
                        onChanged: (value) async {
                          await PreferencesService.saveDarkMode(value);
                          toggleTheme(); // Also call the callback to update the app
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Theme Color',
                        style: TextStyleHelper.h4(),
                      ),
                      Wrap(
                        spacing: 12,
                        children: paletteOptions
                            .map(
                              (color) => GestureDetector(
                                onTap: () => onColorSelected(color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: themeColor == color
                                        ? Border.all(width: 3, color: Colors.black)
                                        : null,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Text Size',
                        style: TextStyleHelper.h4(),
                      ),
                      Wrap(
                        spacing: 12,
                        children: textSizeOptions
                            .map(
                              (size) => ChoiceChip(
                                label: Text(size.toString(), style: TextStyleHelper.body()),
                                selected: textSize == size,
                                onSelected: (_) => onTextSizeChanged(size),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Font Family',
                        style: TextStyleHelper.h4(),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: PreferencesService.fontFamily,
                        builder: (context, currentFont, _) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: fontFamilyOptions
                                .map(
                                  (font) => ChoiceChip(
                                    label: Text(
                                      font,
                                      style: TextStyleHelper.body(
                                        // Apply the font to the chip label for preview
                                      ).copyWith(fontFamily: font),
                                    ),
                                    selected: currentFont == font,
                                    onSelected: (_) {
                                      if (onFontFamilyChanged != null) {
                                        onFontFamilyChanged!(font);
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          'App produced by Triple A productions',
                          style: TextStyleHelper.small(color: Colors.grey),
                        ),
                      )
                    ],
                  ),
                );
              },
                );
              },
            );
          },
        );
      },
    );
  }
}
