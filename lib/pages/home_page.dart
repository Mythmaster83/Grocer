import 'package:flutter/material.dart';
import 'package:grocer_app/widgets/home/upcoming_shopping_display.dart';
import 'package:grocer_app/pages/settings_page.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:grocer_app/services/home_refresh_service.dart';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final Color themeColor;
  final double textSize;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required this.themeColor,
    required this.textSize,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Listen to refresh notifications
    HomeRefreshService.refreshNotifier.addListener(_onRefresh);
  }

  @override
  void dispose() {
    HomeRefreshService.refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive container background color
    final adjustedContainerColor = widget.isDarkMode
        ? Colors.white70.withAlpha(25) // lighter in dark mode
        : Colors.white60; // darker in light mode

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    toggleTheme: widget.toggleTheme,
                    onColorSelected: (color) async {
                      await PreferencesService.saveThemeColor(color);
                    },
                    onTextSizeChanged: (size) async {
                      await PreferencesService.saveTextSize(size);
                    },
                    onFontFamilyChanged: (font) async {
                      await PreferencesService.saveFontFamily(font);
                    },
                  ),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: ValueListenableBuilder<double>(
        valueListenable: PreferencesService.textSize,
        builder: (context, textSize, _) {
          return ValueListenableBuilder<String>(
            valueListenable: PreferencesService.fontFamily,
            builder: (context, fontFamily, _) {
          return ValueListenableBuilder<Color>(
            valueListenable: PreferencesService.themeColor,
            builder: (context, themeColor, _) {
              return Padding(
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 20),
                          ValueListenableBuilder<int>(
                            valueListenable: HomeRefreshService.refreshNotifier,
                            builder: (context, refreshKey, _) {
                              return UpcomingShoppingDisplay(
                                key: ValueKey(refreshKey),
                                adjustedContainerColor: adjustedContainerColor,
                                themeColor: themeColor,
                                textSize: textSize,
                                isDarkMode: widget.isDarkMode,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
              );
            },
          );
        },
      ),
    );
  }
}
