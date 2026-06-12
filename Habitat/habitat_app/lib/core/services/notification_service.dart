import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
  }

  static Future<void> scheduleReminder(int id, String title, String body, DateTime scheduledAt) async {
    final androidDetails = AndroidNotificationDetails('habitat_reminders', 'Habitat Reminders', channelDescription: 'Reminder channel', importance: Importance.max, priority: Priority.high);
    final details = NotificationDetails(android: androidDetails);
    await _plugin.zonedSchedule(id, title, body, scheduledAt.toUtc(), details, androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }
}
