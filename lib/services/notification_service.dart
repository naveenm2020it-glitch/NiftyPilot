import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );
      await _plugin.initialize(settings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification initialization skipped: $e');
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        await androidImpl.requestExactAlarmsPermission();
        return granted ?? true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  int _stableId(String key) => key.hashCode.abs() % 2147483000;

  Future<void> scheduleOneTime({
    required String itemKey,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool enabled,
  }) async {
    await cancelByKey(itemKey);
    if (!enabled) return;
    if (scheduledAt.isBefore(DateTime.now().add(const Duration(seconds: 5)))) return;

    await initialize();
    try {
      final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);
      await _plugin.zonedSchedule(
        _stableId(itemKey),
        title,
        body,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daypilot_reminders',
            'DayPilot Reminders',
            channelDescription: 'Scheduled reminders for tasks, habits, and events',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> scheduleDailyHabit({
    required String habitId,
    required String habitName,
    required String timeHHmm,
    required bool enabled,
  }) async {
    final key = 'habit_$habitId';
    await cancelByKey(key);
    if (!enabled) return;

    final parts = timeHHmm.split(':');
    if (parts.length != 2) return;
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;

    await initialize();
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _stableId(key),
        'Habit Reminder',
        habitName,
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daypilot_habits',
            'Habit Reminders',
            channelDescription: 'Daily habit check-in reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Failed to schedule habit notification: $e');
    }
  }

  Future<void> cancelByKey(String itemKey) async {
    try {
      await _plugin.cancel(_stableId(itemKey));
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
