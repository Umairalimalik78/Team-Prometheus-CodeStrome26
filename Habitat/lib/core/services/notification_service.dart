import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:habitat/features/habit_module/models/habit_module_model.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint("Notification tapped: ${response.payload}");
        // Action callbacks would go here
      },
    );

    // Request permissions on Android 13+
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    _isInitialized = true;
    debugPrint("Habitat: NotificationService initialized.");
  }

  // Schedule reminders based on habit phase
  Future<void> scheduleHabitReminders(HabitModuleModel habit) async {
    await cancelHabitReminders(habit.id);
    if (habit.phase == 5 || habit.status == 'completed') {
      debugPrint("Habit ${habit.habitName} is in autonomous mode, skipping reminders.");
      return;
    }

    // Determine reminder hours depending on phase
    // Phase 1 (1-7 days): 3x daily (8 AM, 1 PM, 8 PM)
    // Phase 2 (8-14 days): 2x daily (8 AM, 8 PM)
    // Phase 3 (15-21 days): 1x daily (8 AM)
    // Phase 4 (22-25 days): Every 2 days (8 AM)
    List<int> hours = [];
    if (habit.phase == 1) {
      hours = [8, 13, 20];
    } else if (habit.phase == 2) {
      hours = [8, 20];
    } else if (habit.phase >= 3) {
      hours = [8];
    }

    final String title = habit.habitName;
    final int baseId = habit.id.hashCode;

    // Schedule notifications for the next 7 days (or phase duration)
    final now = DateTime.now();
    int scheduledCount = 0;

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      // For phase 4, only schedule every 2 days
      if (habit.phase == 4 && dayOffset % 2 != 0) continue;

      for (int i = 0; i < hours.length; i++) {
        final hour = hours[i];
        final scheduledDateTime = DateTime(now.year, now.month, now.day + dayOffset, hour, 0);

        if (scheduledDateTime.isBefore(now)) continue;

        final notificationId = baseId + dayOffset * 10 + i;
        final scheduledTzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);

        String message = _getReminderMessage(habit, hour);

        await _localNotifications.zonedSchedule(
          notificationId,
          title,
          message,
          scheduledTzDateTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'habitat_reminders',
              'Habit Reminders',
              channelDescription: 'Smart daily prompts customized by your AI Coach.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: '${habit.id}|$message',
        );
        scheduledCount++;
      }
    }

    debugPrint("Scheduled $scheduledCount reminders for ${habit.habitName}.");
  }

  Future<void> cancelHabitReminders(String habitId) async {
    final int baseId = habitId.hashCode;
    // Cancel 7 days * 3 slots = 21 possible notification IDs
    for (int dayOffset = 0; dayOffset < 10; dayOffset++) {
      for (int i = 0; i < 3; i++) {
        await _localNotifications.cancel(baseId + dayOffset * 10 + i);
      }
    }
    debugPrint("Cancelled all scheduled notifications for habit: $habitId");
  }

  // Instantly trigger a mock notification for testing/demo
  Future<void> showInstantNotification(String title, String body, {String? payload}) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'habitat_test',
        'Demo Notifications',
        channelDescription: 'Instantly triggered notifications for review/demo.',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
      ),
    );

    final randomId = Random().nextInt(10000);
    await _localNotifications.show(randomId, title, body, notificationDetails, payload: payload);
  }

  // Snoozes a reminder by 30 mins
  Future<void> snoozeNotification(String habitId, String content) async {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 30));
    final scheduledTzDateTime = tz.TZDateTime.from(snoozeTime, tz.local);

    final int snoozeId = habitId.hashCode + 999; // Unique slot for snooze

    await _localNotifications.zonedSchedule(
      snoozeId,
      "Snoozed: $habitId",
      content,
      scheduledTzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitat_snoozes',
          'Snoozed Reminders',
          channelDescription: 'Reminders delayed by 30 minutes.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint("Snoozed notification for $habitId by 30 mins.");
  }

  // Helper to generate context-aware message depending on the time of day
  String _getReminderMessage(HabitModuleModel habit, int hour) {
    if (habit.envDesignTips.isEmpty) {
      return "Time to focus on your habit: ${habit.habitName}!";
    }

    final randTip = habit.envDesignTips[Random().nextInt(habit.envDesignTips.length)];

    if (hour < 12) {
      return "Morning routine: your habit is waiting! Tip: $randTip";
    } else if (hour < 18) {
      return "Mid-day check-in! Keep the momentum going. $randTip";
    } else {
      return "Evening wind-down. Focus on yourself: $randTip";
    }
  }
}
