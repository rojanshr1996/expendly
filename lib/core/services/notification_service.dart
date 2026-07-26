import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';

/// Top-level background message handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling background message: ${message.messageId}');
  }
}

@lazySingleton
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'expendly_channel';
  static const String channelName = 'Expendly Notifications';
  static const String channelDescription =
      'Notifications for transactions, financial insights, and system alerts.';

  final StreamController<Map<String, dynamic>> _onNotificationClick =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationClick =>
      _onNotificationClick.stream;

  /// Initializes FCM and local notifications service.
  Future<void> initialize() async {
    // 1. Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request Notification Permissions
    await _requestPermissions();

    // 3. Initialize Local Notifications Plugin
    await _initLocalNotifications();

    // 4. Configure FCM Foreground Listener
    _listenForegroundMessages();

    // 5. Handle App Launch from Notification
    await _checkInitialNotification();

    // 6. Subscribe to flavor specific FCM topic
    await _subscribeToFlavorTopic();
  }

  /// Request permissions for FCM & Local Notifications (iOS & Android 13+)
  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('User granted notification permission: ${settings.authorizationStatus}');
    }
  }

  /// Initialize flutter_local_notifications with platform settings & android channel
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    // Create Android High Importance Notification Channel
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _onNotificationClick.add(data);
          } catch (_) {
            _onNotificationClick.add({'payload': response.payload});
          }
        }
      },
    );
  }

  /// Listen for incoming FCM messages while app is in foreground
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        showLocalNotification(
          id: message.messageId.hashCode,
          title: notification.title ?? 'Expendly Alert',
          body: notification.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationClick.add(message.data);
    });
  }

  /// Check if application was launched directly by clicking a notification
  Future<void> _checkInitialNotification() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationClick.add(initialMessage.data);
    }
  }

  /// Subscribe device to flavor topic (e.g. expendly_dev, expendly_prod)
  Future<void> _subscribeToFlavorTopic() async {
    final topic = 'expendly_${AppConfig.instance.flavor.name}';
    try {
      await _fcm.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to FCM topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to FCM topic $topic: $e');
      }
    }
  }

  /// Displays a local notification on device
  Future<void> showLocalNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Get current device FCM Token
  Future<String?> getFcmToken() async {
    try {
      final token = await _fcm.getToken();
      if (kDebugMode) {
        print('FCM Registration Token: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching FCM Token: $e');
      }
      return null;
    }
  }

  void dispose() {
    _onNotificationClick.close();
  }
}
