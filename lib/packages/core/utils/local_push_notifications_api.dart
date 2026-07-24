import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'platform_utils.dart';

class NotificationApi {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final BehaviorSubject<String?> onNotification =
      BehaviorSubject<String?>();

  static bool _timezoneInitialized = false;

  static Future<void> init({bool initScheduled = false}) async {
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestCriticalPermission: true,
          requestSoundPermission: true,
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
        );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) async {
        onNotification.add(details.payload);
      },
      onDidReceiveBackgroundNotificationResponse: (details) async {
        onNotification.add(details.payload);
      },
    );

    if (!initScheduled || _timezoneInitialized) {
      return;
    }

    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final locationName = timezoneInfo.identifier;
      PlatformUtils.debugLog(
        NotificationApi,
        'FlutterTimezone location: $locationName',
      );
      tz.setLocalLocation(tz.getLocation(locationName));
      _timezoneInitialized = true;
    } catch (e, st) {
      PlatformUtils.debugLog(
        NotificationApi,
        'FlutterTimezone init error: $e\n$st',
      );
    }
  }

  static Future<void> requestNotificationPermission() async {
    if (PlatformUtils.isAndroid()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (PlatformUtils.isIOS()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (PlatformUtils.isMacOS()) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: await _notificationDetails(),
      payload: payload,
    );
  }

  static Future<void> showProgressNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required int progress,
    required int maxProgress,
  }) async {
    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
          threadIdentifier: 'coozy_the_cafe_app_progress',
        ),
        android: AndroidNotificationDetails(
          'coozy_the_cafe_app_notification_progress',
          'Database Backup Progress',
          channelDescription: 'Shows progress for database backups',
          priority: Priority.low,
          category: AndroidNotificationCategory.progress,
          importance: Importance.low,
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          onlyAlertOnce: true,
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> showScheduledNotification({
    required DateTime scheduledDate,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  static Future<void> showDailyNotification({
    required DateTime time,
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _scheduledDaily(time),
      notificationDetails: await _notificationDetails(),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _scheduledDaily(DateTime time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  static Future<NotificationDetails> _notificationDetails() async {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'coozy_the_cafe_app',
      ),
      android: AndroidNotificationDetails(
        'coozy_the_cafe_app_notification',
        'Coozy Cafe App Notifications',
        channelDescription: 'All notifications sent by the Coozy cafe app',
        priority: Priority.high,
        category: AndroidNotificationCategory.service,
        importance: Importance.max,
      ),
    );
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
