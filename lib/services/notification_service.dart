import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../services/database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data (non-blocking)
      if (!tz.timeZoneDatabase.isInitialized) {
        tz.initializeTimeZones();
      }
      
      // Get system timezone or default
      try {
        final location = tz.local;
        tz.setLocalLocation(location);
      } catch (e) {
        // Fallback to default timezone if system timezone fails
        final location = tz.getLocation('America/New_York');
        tz.setLocalLocation(location);
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized != null && initialized) {
        _initialized = true;
      }
    } catch (e) {
      // Silently handle errors - app should work without notifications
      _initialized = false;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  static Future<void> scheduleShoppingReminders() async {
    if (!_initialized) {
      await initialize();
    }
    
    if (!_initialized) {
      // If initialization failed, skip scheduling
      return;
    }

    try {
      // Cancel all existing notifications
      await _notifications.cancelAll();

      // Get all shopping lists with schedules
      final lists = await DatabaseService.getShoppingLists();
      final now = DateTime.now();

      for (final list in lists) {
        if (list.frequency == null && list.scheduledDate == null) continue;

        final nextDate = list.getNextShoppingDate();
        if (nextDate == null) continue;

        // Schedule reminder for 1 day before
        final reminderDate = nextDate.subtract(const Duration(days: 1));
        
        // Only schedule if reminder is in the future
        if (reminderDate.isAfter(now)) {
          try {
            await _scheduleNotification(
              id: list.id.toInt(),
              title: 'Shopping Reminder',
              body: 'Don\'t forget to shop for "${list.name}" tomorrow!',
              scheduledDate: reminderDate,
            );
          } catch (e) {
            // Continue with other notifications if one fails
          }
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'shopping_reminders',
      'Shopping Reminders',
      channelDescription: 'Reminders for upcoming shopping days',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}

