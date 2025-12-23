import 'package:flutter/material.dart';
import 'package:grocer_app/utils/text_style_helper.dart';
import 'package:grocer_app/services/preferences_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MicPermissionDialog extends StatelessWidget {
  final Function()? onGranted;
  final Function()? onDenied;

  const MicPermissionDialog({
    super.key,
    this.onGranted,
    this.onDenied,
  });

  static Future<bool> checkAndRequestPermission(BuildContext context) async {
    final speech = stt.SpeechToText();
    
    // Check if speech recognition is available
    final available = await speech.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
    
    if (!available) {
      return false;
    }

    // Check current permission status
    final hasPermission = await speech.hasPermission;
    
    return hasPermission;
  }

  static Future<void> show(BuildContext context, {Function()? onGranted, Function()? onDenied}) async {
    final speech = stt.SpeechToText();
    
    // Initialize to check availability
    final available = await speech.initialize(
      onError: (error) {},
      onStatus: (status) {},
    );
    
    if (!available) {
      // Show error dialog if speech recognition is not available
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (context) => ValueListenableBuilder<double>(
            valueListenable: PreferencesService.textSize,
            builder: (context, textSize, _) => ValueListenableBuilder<bool>(
              valueListenable: PreferencesService.isDarkMode,
              builder: (context, isDarkMode, _) => Opacity(
                opacity: 1.0,
                child: AlertDialog(
                  backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                  title: Text('Speech Recognition Unavailable', style: TextStyleHelper.h4()),
                content: Text(
                  'Speech recognition is not available on this device. Please ensure your device supports speech recognition.',
                  style: TextStyleHelper.body(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK', style: TextStyleHelper.body()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    onDenied?.call();
      return;
    }

    // Check current permission status
    final hasPermission = await speech.hasPermission;
    
    if (hasPermission) {
      onGranted?.call();
      return;
    }

    // Show permission request dialog
    if (context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => MicPermissionDialog(
          onGranted: onGranted,
          onDenied: onDenied,
        ),
      );

      if (result == true) {
        // User wants to grant permission
        // The permission will be requested when speech recognition is initialized
        // Re-check permission after attempting to use it
        final hasPermission = await speech.hasPermission;
        
        if (hasPermission && context.mounted) {
          onGranted?.call();
        } else if (context.mounted) {
          // Permission still not granted - system will prompt on first use
          // Try to initialize again to trigger system permission dialog
          final initialized = await speech.initialize(
            onError: (error) {},
            onStatus: (status) {},
          );
          
          if (initialized) {
            final permissionAfterInit = await speech.hasPermission;
            if (permissionAfterInit && context.mounted) {
              onGranted?.call();
            } else if (context.mounted) {
              // Permission denied
              await showDialog(
                context: context,
                builder: (context) => ValueListenableBuilder<double>(
                  valueListenable: PreferencesService.textSize,
                  builder: (context, textSize, _) => ValueListenableBuilder<bool>(
                    valueListenable: PreferencesService.isDarkMode,
                    builder: (context, isDarkMode, _) => Opacity(
                      opacity: 1.0,
                      child: AlertDialog(
                        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                        title: Text('Permission Denied', style: TextStyleHelper.h4()),
                      content: Text(
                        'Microphone permission is required for voice input. Please enable it in your device settings.',
                        style: TextStyleHelper.body(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK', style: TextStyleHelper.body()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
              onDenied?.call();
            }
          } else {
            onDenied?.call();
          }
        }
      } else {
        onDenied?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: PreferencesService.textSize,
      builder: (context, textSize, _) => ValueListenableBuilder<bool>(
        valueListenable: PreferencesService.isDarkMode,
        builder: (context, isDarkMode, _) => Opacity(
          opacity: 1.0,
          child: AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[200],
          title: Text('Microphone Permission', style: TextStyleHelper.h4()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.mic,
                size: 48,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'This app needs access to your microphone to use voice input.',
                style: TextStyleHelper.body(),
              ),
              const SizedBox(height: 8),
              Text(
                'You can add items to your lists by speaking them. For example: "2 apples, 3 bananas, milk".',
                style: TextStyleHelper.small(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                onDenied?.call();
              },
              child: Text('Cancel', style: TextStyleHelper.body()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Grant Permission', style: TextStyleHelper.body()),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

