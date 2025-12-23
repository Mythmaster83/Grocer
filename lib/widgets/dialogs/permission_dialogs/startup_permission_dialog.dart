import 'package:flutter/material.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class StartupPermissionDialog extends StatelessWidget {
  final VoidCallback? onComplete;

  const StartupPermissionDialog({
    super.key,
    this.onComplete,
  });

  /// Check if all required permissions are granted
  static Future<bool> checkAllPermissions() async {
    try {
      // Check microphone permission
      bool micPermission = false;
      try {
        final speech = stt.SpeechToText();
        final speechAvailable = await speech.initialize(
          onError: (error) {},
          onStatus: (status) {},
        ).timeout(const Duration(seconds: 5), onTimeout: () => false);
        
        if (speechAvailable == true) {
          micPermission = await speech.hasPermission;
        }
      } catch (e) {
        // If microphone check fails, assume not granted
        micPermission = false;
      }

      // Check notification permission (Android 13+)
      bool notificationPermission = true; // Default to true for older Android versions
      try {
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        final androidImplementation = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation != null) {
          // For Android 13+, check if permission is already granted
          final granted = await androidImplementation.areNotificationsEnabled()
              .timeout(const Duration(seconds: 3), onTimeout: () => null);
          notificationPermission = granted ?? true; // Default to true if check fails
        }
      } catch (e) {
        // If check fails, assume permission is granted (older Android versions)
        notificationPermission = true;
      }

      return micPermission && notificationPermission;
    } catch (e) {
      // If all checks fail, assume permissions are not granted
      return false;
    }
  }

  /// Show permission dialog if needed
  static Future<void> showIfNeeded(BuildContext context) async {
    try {
      // Add a small delay to ensure the app is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!context.mounted) return;
      
      final allGranted = await checkAllPermissions();
      
      if (allGranted) {
        // All permissions granted, no need to show dialog
        return;
      }

      // Show dialog to request permissions
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const StartupPermissionDialog(),
        );
      }
    } catch (e) {
      // Silently handle errors - don't crash the app
    }
  }

  Future<void> _requestPermissions(BuildContext context) async {
    try {
      final speech = stt.SpeechToText();
      
      // Request microphone permission
      bool micPermission = false;
      try {
        final speechAvailable = await speech.initialize(
          onError: (error) {},
          onStatus: (status) {},
        ).timeout(const Duration(seconds: 5), onTimeout: () => false);
        
        if (speechAvailable == true) {
          micPermission = await speech.hasPermission;
          if (!micPermission) {
            // Try to trigger permission request by attempting to use it
            // The system will show the permission dialog when we try to listen
            try {
              await speech.initialize(
                onError: (error) {},
                onStatus: (status) {},
              ).timeout(const Duration(seconds: 5), onTimeout: () => false);
              // Re-check after initialization
              micPermission = await speech.hasPermission;
            } catch (e) {
              // Ignore re-initialization errors
            }
          }
        }
      } catch (e) {
        // Ignore microphone permission errors
      }

      // Request notification permission (Android 13+)
      try {
        final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
        final androidImplementation = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidImplementation != null) {
          await androidImplementation.requestNotificationsPermission()
              .timeout(const Duration(seconds: 3), onTimeout: () => false);
        }
      } catch (e) {
        // Ignore errors for notification permission (older Android versions)
      }

      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Close dialog even if there's an error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('App Permissions', style: TextStyleHelper.h4()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This app needs the following permissions to work properly:',
                  style: TextStyleHelper.body(),
                ),
                const SizedBox(height: 16),
                _buildPermissionItem(
                  icon: Icons.mic,
                  title: 'Microphone Permission',
                  description: 'Required for voice input to add items to your shopping lists.',
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildPermissionItem(
                  icon: Icons.notifications,
                  title: 'Notification Permission',
                  description: 'Required to send you reminders about upcoming shopping days.',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Skip', style: TextStyleHelper.body()),
            ),
            ElevatedButton(
              onPressed: () => _requestPermissions(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Grant Permissions', style: TextStyleHelper.body()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyleHelper.bodyBold(),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyleHelper.small(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

