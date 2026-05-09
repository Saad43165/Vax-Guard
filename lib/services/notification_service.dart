import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();

  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const vaccineChannel = AndroidNotificationChannel(
      AppConstants.vaccineReminderChannelId,
      AppConstants.vaccineReminderChannelName,
      description: 'Reminders for upcoming vaccine doses',
      importance: Importance.high,
    );

    const outbreakChannel = AndroidNotificationChannel(
      AppConstants.outbreakAlertChannelId,
      AppConstants.outbreakAlertChannelName,
      description: 'Live disease outbreak proximity alerts',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(vaccineChannel);
    await androidPlugin?.createNotificationChannel(outbreakChannel);
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> requestPermissions() async {
    final android = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> scheduleVaccineReminder({
    required String vaccineId,
    required String vaccineName,
    required DateTime reminderDate,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.vaccineReminderChannelId,
      AppConstants.vaccineReminderChannelName,
      channelDescription: 'Reminders for upcoming vaccine doses',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a unique notification ID based on vaccineId hash
    final notificationId = vaccineId.hashCode.abs() % 100000;

    await _notificationsPlugin.show(
      notificationId,
      '💉 Vaccine Reminder',
      'Time for your $vaccineName dose!',
      notificationDetails,
      payload: vaccineId,
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final quietStartRaw = prefs.getString('quiet_start');
    final quietEndRaw = prefs.getString('quiet_end');
    if (_isInQuietHours(quietStartRaw, quietEndRaw)) {
      // Respect quiet hours for non-critical notifications.
      if (!(title.toLowerCase().contains('urgent') ||
          body.toLowerCase().contains('emergency'))) {
        return;
      }
    }
    final androidDetails = AndroidNotificationDetails(
      AppConstants.vaccineReminderChannelId,
      AppConstants.vaccineReminderChannelName,
      channelDescription: 'VaxGuard notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      AppConstants.vaccineReminderNotificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  bool _isInQuietHours(String? startRaw, String? endRaw) {
    if (startRaw == null || endRaw == null) return false;
    final startParts = startRaw.split(':');
    final endParts = endRaw.split(':');
    if (startParts.length != 2 || endParts.length != 2) return false;
    final startMinutes =
        (int.tryParse(startParts[0]) ?? 22) * 60 + (int.tryParse(startParts[1]) ?? 0);
    final endMinutes =
        (int.tryParse(endParts[0]) ?? 7) * 60 + (int.tryParse(endParts[1]) ?? 0);
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    }
    return currentMinutes >= startMinutes || currentMinutes < endMinutes;
  }

  Future<void> cancelNotification(String vaccineId) async {
    final notificationId = vaccineId.hashCode.abs() % 100000;
    await _notificationsPlugin.cancel(notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Shows a high-priority outbreak alert notification.
  Future<void> showOutbreakAlert({
    required String disease,
    required String region,
    required String severity,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.outbreakAlertChannelId,
      AppConstants.outbreakAlertChannelName,
      channelDescription: 'Live disease outbreak proximity alerts',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF3B30),
      ticker: '⚠️ Outbreak Alert',
      styleInformation: BigTextStyleInformation(
        '[$severity Risk] $disease has been detected in $region. Open VaxGuard for WHO prevention guidelines.',
        contentTitle: '⚠️ Outbreak Alert: $disease',
        summaryText: 'Tap to view prevention steps',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    await _notificationsPlugin.show(
      9001,
      '⚠️ Outbreak Alert: $disease',
      '[$severity] Detected in $region. Tap for WHO guidelines.',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: 'outbreak_alert',
    );
  }

  /// Schedules a simulated proximity alert for demo/testing.
  Future<void> scheduleProximityAlertDemo() async {
    // Show a "Service Active" notification first
    final androidDetails = AndroidNotificationDetails(
      AppConstants.outbreakAlertChannelId,
      AppConstants.outbreakAlertChannelName,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: false,
      autoCancel: true,
      showWhen: true,
    );

    await _notificationsPlugin.show(
      8888,
      '🛡️ VaxGuard Radar Active',
      'Proximity alerts are now monitoring your region.',
      NotificationDetails(android: androidDetails),
    );

    // Simulate an actual alert after 3 seconds for demo purposes
    Future.delayed(const Duration(seconds: 3), () async {
      await showOutbreakAlert(
        disease: 'Seasonal Influenza (H1N1)',
        region: 'Localized Urban Area',
        severity: 'Moderate',
      );
    });
  }
}
