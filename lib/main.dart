import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:grocer_app/pages/home_page.dart';
import 'package:grocer_app/pages/lists_page.dart';
import 'package:grocer_app/pages/settings_page.dart';
import 'package:grocer_app/pages/stocks_page.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:grocer_app/services/database_service.dart';
import 'package:grocer_app/services/notification_service.dart';
import 'package:grocer_app/widgets/dialogs/permission_dialogs/startup_permission_dialog.dart';
import 'package:grocer_app/data/grocery_items.dart';
import 'package:grocer_app/data/item_units.dart';
import 'package:grocer_app/services/env_service.dart';
import 'package:grocer_app/services/image_check_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from key.env
  debugPrint('[main] Loading environment variables...');
  await EnvService.load();
  debugPrint('[main] Environment variables loaded. Checking PEXELS_API_KEY...');
  final apiKey = EnvService.get('PEXELS_API_KEY');
  if (apiKey != null) {
    debugPrint('[main] PEXELS_API_KEY status: Found (length: ${apiKey.length})');
    debugPrint('[main] PEXELS_API_KEY first 10 chars: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
  } else {
    debugPrint('[main] PEXELS_API_KEY status: NOT FOUND');
    debugPrint('[main] WARNING: Images will not be fetched without API key');
  }
  
  // Set up error handling according to Flutter documentation
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // In release mode, you might want to report to a crash reporting service
    if (kReleaseMode) {
      // Report to crash reporting service here if needed
    }
  };

  // Handle errors not caught by Flutter (async errors)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    // Report to crash reporting service here if needed
    return true; // Return true to indicate error was handled
  };
  
  try {
    // Initialize database
    await DatabaseService.instance;
    
    // Load custom grocery items
    await GroceryItems.loadCustomItems();
    
    // Load item units
    await ItemUnits.loadCustomUnits();
    
    // Load preferences (will detect system settings if not set)
    await PreferencesService.loadPreferences();
    
    // Start periodic image checks (every 15 minutes)
    ImageCheckService.startPeriodicChecks();
  } catch (e, stackTrace) {
    // Handle initialization errors gracefully
    // Continue running the app even if some initialization fails
  }

  // Run app immediately - notifications will initialize after app starts
  runApp(const GrocerApp());
}

class GrocerApp extends StatefulWidget {
  const GrocerApp({super.key});

  @override
  State<GrocerApp> createState() => _GrocerAppState();
}

class _GrocerAppState extends State<GrocerApp> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    // Initialize notifications asynchronously after app starts
    _initializeNotifications();
  }


  void _initializeNotifications() async {
    // Wait for first frame to ensure plugin is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NotificationService.initialize();
        await NotificationService.scheduleShoppingReminders();
      } catch (e) {
        // Silently handle notification initialization errors
        // App should still work without notifications
      }
    });
  }

  void toggleTheme() async {
    // This is called from settings page which already saves the value
    // Just trigger a rebuild by updating the notifier (already done in saveDarkMode)
    // No need to do anything here as the ValueListenableBuilder will rebuild automatically
  }

  void updateThemeColor(Color color) async {
    await PreferencesService.saveThemeColor(color);
  }

  void updateTextSize(double size) async {
    await PreferencesService.saveTextSize(size);
  }

  Widget pageFromKey(String key) {
    switch (key) {
      case 'home':
        return HomePage(
          isDarkMode: PreferencesService.isDarkMode.value,
          toggleTheme: toggleTheme,
          themeColor: PreferencesService.themeColor.value,
          textSize: PreferencesService.textSize.value,
        );
      case 'stock':
        return StockPage();
      case 'lists':
        return ShoppingListsPage();
      case 'settings':
        return SettingsPage(
          toggleTheme: toggleTheme,
          onColorSelected: updateThemeColor,
          onTextSizeChanged: updateTextSize,
        );
      default:
        return const Center(child: Text('Unknown page'));
    }
  }

  Icon iconForPage(String key) {
    final isDarkMode = PreferencesService.isDarkMode.value;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black87;
    switch (key) {
      case 'home':
        return Icon(Icons.home, color: iconColor);
      case 'stock':
        return Icon(Icons.inventory_2, color: iconColor);
      case 'lists':
        return Icon(Icons.list_alt, color: iconColor);
      case 'settings':
        return Icon(Icons.settings, color: iconColor);
      default:
        return Icon(Icons.help_outline, color: iconColor);
    }
  }

  String labelForPage(String key) {
    switch (key) {
      case 'home':
        return 'Home';
      case 'stock':
        return 'Stock';
      case 'lists':
        return 'Lists';
      case 'settings':
        return 'Settings';
      default:
        return 'Unknown';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PreferencesService.isDarkMode,
      builder: (context, darkMode, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: PreferencesService.themeColor,
          builder: (context, color, _) {
            return ValueListenableBuilder<double>(
              valueListenable: PreferencesService.textSize,
              builder: (context, size, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  builder: (BuildContext context, Widget? widget) {
                    // Set up error widget builder for build phase errors
                    Widget error = Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'An error occurred during rendering.',
                              style: TextStyle(fontSize: size),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please restart the app.',
                              style: TextStyle(fontSize: size * 0.875, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                    
                    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                      return error;
                    };
                    
                    if (widget != null) return widget;
                    return error;
                  },
                  theme: ThemeData(
                    brightness: darkMode ? Brightness.dark : Brightness.light,
                    primarySwatch: createMaterialColor(color),
                    textTheme: TextTheme(
                      bodyMedium: TextStyle(fontSize: size),
                    ),
                    // Ensure Material Icons are available - they use their own font family
                    iconTheme: IconThemeData(
                      color: darkMode ? Colors.white70 : Colors.black87,
                    ),
                    useMaterial3: true,
                  ),
                  home: ValueListenableBuilder<List<String>>(
                    valueListenable: PreferencesService.pageOrder,
                    builder: (context, pages, _) {
                      // Ensure currentIndex is valid
                      final safeIndex = pages.isEmpty 
                          ? 0 
                          : currentIndex.clamp(0, pages.length - 1);
                      
                      // If pages changed and current index is invalid, reset it
                      if (currentIndex != safeIndex && pages.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              currentIndex = safeIndex;
                            });
                            if (_pageController.hasClients && safeIndex < pages.length) {
                              _pageController.jumpToPage(safeIndex);
                            }
                          }
                        });
                      }
                      
                      return _PermissionWrapper(
                        child: Scaffold(
                          body: pages.isEmpty
                              ? const Center(child: Text('No pages available'))
                              : PageView(
                                  key: ValueKey(pages.join('-')), // Rebuild when order changes
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    if (mounted && index < pages.length) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    }
                                  },
                                  children: pages.map((key) => pageFromKey(key)).toList(),
                                ),
                          bottomNavigationBar: pages.isEmpty
                              ? null
                              : BottomNavigationBar(
                                  currentIndex: safeIndex,
                                  onTap: (index) {
                                    if (index < pages.length && _pageController.hasClients) {
                                      _pageController.animateToPage(
                                        index,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  items: pages
                                      .map((key) => BottomNavigationBarItem(
                                    icon: iconForPage(key),
                                    label: labelForPage(key),
                                  ))
                                      .toList(),
                                  selectedItemColor: color,
                                  unselectedItemColor: darkMode ? Colors.white30 : Colors.grey[600],
                                ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List<double> strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = (color.r * 255.0).round() & 0xff;
  final int g = (color.g * 255.0).round() & 0xff;
  final int b = (color.b * 255.0).round() & 0xff;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }

  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.toARGB32(), swatch);
}

/// Wrapper widget that shows permission dialog on first build
class _PermissionWrapper extends StatefulWidget {
  final Widget child;

  const _PermissionWrapper({required this.child});

  @override
  State<_PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<_PermissionWrapper> {
  bool _hasCheckedPermissions = false;

  @override
  void initState() {
    super.initState();
    // Check permissions after first frame with a delay to ensure app is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _checkPermissions();
        }
      });
    });
  }

  Future<void> _checkPermissions() async {
    if (_hasCheckedPermissions || !mounted) return;
    _hasCheckedPermissions = true;

    try {
      if (mounted) {
        await StartupPermissionDialog.showIfNeeded(context);
      }
    } catch (e) {
      // Silently handle errors - don't crash the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
