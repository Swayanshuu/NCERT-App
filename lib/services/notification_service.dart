import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _channelId = 'ncert_study_reminders';
  static const String _channelName = 'Study Reminders & Daily Rewards';
  static const String _channelDesc = 'Notifications for daily bonus XP, study streak warnings, and learning reminders.';

  // Notification IDs
  static const int _id12HoursReminder = 101;
  static const int _id22HoursEmergency = 102;
  static const int _idDailyBonus = 103;

  Future<void> init() async {
    if (_isInitialized || kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      _isInitialized = true;
      return;
    }

    try {
      tz.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
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

      await _notificationsPlugin.initialize(settings: initSettings);

      // Create Android Notification Channel
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
      );

      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        try {
          await androidPlugin.requestNotificationsPermission();
        } catch (e) {
          debugPrint('Notification permission error: $e');
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Called whenever the user opens/resumes the app.
  /// Tracks app launch, cancels old pending reminders, and schedules fresh creative reminders:
  /// - 12 Hours Inactivity Reminder
  /// - 22 Hours Danger Streak Expiry Reminder
  /// - Daily Bonus XP Claim Reminder
  Future<void> trackAppOpen({
    required String userName,
    required int streakDays,
    required bool canClaimBonus,
    required int hoursUntilBonus,
  }) async {
    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) return;
    await init();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_app_open_timestamp', DateTime.now().millisecondsSinceEpoch);

      // Cancel previous scheduled reminders so we don't spam the user
      await _notificationsPlugin.cancel(id: _id12HoursReminder);
      await _notificationsPlugin.cancel(id: _id22HoursEmergency);
      await _notificationsPlugin.cancel(id: _idDailyBonus);

      final name = userName.isEmpty ? 'Student' : userName;

      // 1. Schedule 12-Hour Re-engagement Notification
      final time12h = tz.TZDateTime.now(tz.local).add(const Duration(hours: 12));
      await _scheduleNotification(
        id: _id12HoursReminder,
        title: '🦉 Hey $name, your mascot companion misses you!',
        body: 'Keep your study momentum going! Spend just 5 minutes reading your NCERT textbooks today.',
        scheduledDate: time12h,
      );

      // 2. Schedule 22-Hour Danger Streak Expiry Notification (2 hours before streak resets!)
      final time22h = tz.TZDateTime.now(tz.local).add(const Duration(hours: 22));
      final streakText = streakDays > 0 ? '$streakDays-Day' : 'Active';
      await _scheduleNotification(
        id: _id22HoursEmergency,
        title: '🚨 DANGER! Your $streakText Study Streak is About to Expire!',
        body: 'Only 2 hours left today! Open NCERT Books now to save your hard-earned streak & claim free XP!',
        scheduledDate: time22h,
      );

      // 3. Schedule / Show Daily Bonus Claim Notification
      if (canClaimBonus) {
        await _showNotification(
          id: _idDailyBonus,
          title: '🎁 Daily XP Bonus Ready to Claim!',
          body: 'Hey $name! Your daily +50 XP bonus is waiting. Tap here to claim your reward & level up!',
        );
      } else if (hoursUntilBonus > 0) {
        final bonusTime = tz.TZDateTime.now(tz.local).add(Duration(hours: hoursUntilBonus));
        await _scheduleNotification(
          id: _idDailyBonus,
          title: '🎁 Daily XP Bonus Unlocked!',
          body: 'Your next daily +50 XP reward is ready to claim! Don\'t miss out on leveling up.',
          scheduledDate: bonusTime,
        );
      }
    } catch (e) {
      debugPrint('trackAppOpen error: $e');
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('zonedSchedule error: $e');
    }
  }
}
