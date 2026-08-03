import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_config.dart';
import '../models/notification_payload.dart';
import '../utils/app_logger.dart';

/// Helper to download image from URL and save locally for notification attachments
Future<String?> _downloadAndSaveNotificationImage(
    String url, String fileName) async {
  try {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';
    final File file = File(filePath);

    final HttpClient client = HttpClient();
    final HttpClientRequest request = await client.getUrl(Uri.parse(url));
    final HttpClientResponse response = await request.close();

    if (response.statusCode == 200) {
      final bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
      return filePath;
    }
  } catch (e) {
    AppLogger.e('Failed to download notification image from URL: $url', e);
  }
  return null;
}

/// Helper to extract image URL from RemoteMessage
String? _extractImageUrl(RemoteMessage message) {
  final notification = message.notification;
  if (notification != null) {
    if (notification.android?.imageUrl != null &&
        notification.android!.imageUrl!.isNotEmpty) {
      return notification.android!.imageUrl;
    }
    if (notification.apple?.imageUrl != null &&
        notification.apple!.imageUrl!.isNotEmpty) {
      return notification.apple!.imageUrl;
    }
  }
  final data = message.data;
  final dataImage =
      data['image'] ?? data['imageUrl'] ?? data['image_url'] ?? data['picture'];
  if (dataImage != null && dataImage.toString().trim().isNotEmpty) {
    return dataImage.toString().trim();
  }
  return null;
}

/// Top-level background message handler required by Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
  AppLogger.i('FCM Handling background message: ${message.messageId}');

  final notification = message.notification;
  if (notification != null) {
    final bgNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await bgNotifications.initialize(initSettings);

    final imageUrl = _extractImageUrl(message);
    String? localImagePath;
    if (imageUrl != null) {
      localImagePath = await _downloadAndSaveNotificationImage(
        imageUrl,
        'bg_notification_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    BigPictureStyleInformation? bigPictureStyle;
    if (localImagePath != null) {
      bigPictureStyle = BigPictureStyleInformation(
        FilePathAndroidBitmap(localImagePath),
        largeIcon: FilePathAndroidBitmap(localImagePath),
        contentTitle: notification.title ?? 'Expendly Alert',
        summaryText: notification.body ?? '',
        hideExpandedLargeIcon: true,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      NotificationService.channelId,
      NotificationService.channelName,
      channelDescription: NotificationService.channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigPictureStyle,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: localImagePath != null
            ? [DarwinNotificationAttachment(localImagePath)]
            : null,
      ),
    );

    await bgNotifications.show(
      message.messageId.hashCode,
      notification.title ?? 'Expendly Alert',
      notification.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
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

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final StreamController<String> _onTokenRefresh =
      StreamController<String>.broadcast();
  Stream<String> get onTokenRefresh => _onTokenRefresh.stream;

  final StreamController<Map<String, dynamic>> _onNotificationClick =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onNotificationClick =>
      _onNotificationClick.stream;

  final StreamController<NotificationActionPayload> _onNotificationAction =
      StreamController<NotificationActionPayload>.broadcast();
  Stream<NotificationActionPayload> get onNotificationAction =>
      _onNotificationAction.stream;

  /// Initializes FCM and local notifications service.
  Future<void> initialize() async {
    AppLogger.i('Initializing NotificationService...');

    // 1. Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 2. Request Notification Permissions
    await _requestPermissions();

    // 3. Initialize Local Notifications Plugin
    await _initLocalNotifications();

    // 4. Listen for Token Refresh
    _fcm.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      AppLogger.i('FCM Token refreshed: $newToken');
      _onTokenRefresh.add(newToken);
    });

    // 5. Fetch & Generate FCM Token
    await getFcmToken();

    // 6. Configure FCM Foreground Listener
    _listenForegroundMessages();

    // 7. Handle App Launch from Notification
    await _checkInitialNotification();

    // 8. Subscribe to flavor specific FCM topic
    await _subscribeToFlavorTopic();

    AppLogger.i('NotificationService initialization complete');
  }

  /// Request permissions for FCM & Local Notifications (iOS & Android 13+)
  Future<void> _requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    AppLogger.i(
        'Notification permission status: ${settings.authorizationStatus}');

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
  }

  /// Initialize flutter_local_notifications with platform settings & android channel
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
    }

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _onNotificationClick.add(data);
            final actionPayload = NotificationActionPayload.fromMap(data);
            await _handleActionPayload(actionPayload);
            _onNotificationAction.add(actionPayload);
          } catch (_) {
            _onNotificationClick.add({'payload': response.payload});
            final actionPayload = NotificationActionPayload.fromMap(
                {'payload': response.payload});
            await _handleActionPayload(actionPayload);
            _onNotificationAction.add(actionPayload);
          }
        }
      },
    );
  }

  /// Launches an external URL using url_launcher package.
  Future<bool> launchExternalUrl(String urlString) async {
    try {
      String formattedUrl = urlString.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://') &&
          !formattedUrl.startsWith('mailto:') &&
          !formattedUrl.startsWith('tel:')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        AppLogger.i(
            'Launching external URL from NotificationService: $formattedUrl');
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.w('Cannot launch external URL: $formattedUrl');
      }
    } catch (e, stackTrace) {
      AppLogger.e('Error launching external URL: $urlString', e, stackTrace);
    }
    return false;
  }

  /// Automatically launches link using url launcher when actionType is externalUrl or payload is a URL action.
  Future<void> _handleActionPayload(
      NotificationActionPayload actionPayload) async {
    if (actionPayload.isUrlAction ||
        actionPayload.actionType?.toLowerCase() == 'externalurl' ||
        actionPayload.actionType?.toLowerCase() == 'external_url') {
      final url = actionPayload.urlToOpen ??
          actionPayload.action ??
          actionPayload.target;
      if (url != null && url.trim().isNotEmpty) {
        AppLogger.i(
            'Opening link via url_launcher for actionType ${actionPayload.actionType}: $url');
        await launchExternalUrl(url);
      }
    }
  }

  /// Listen for incoming FCM messages while app is in foreground
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final imageUrl = _extractImageUrl(message);

      if (notification != null) {
        await showLocalNotification(
          id: message.messageId.hashCode,
          title: notification.title ?? 'Expendly Alert',
          body: notification.body ?? '',
          imageUrl: imageUrl,
          payload: jsonEncode(message.data),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _onNotificationClick.add(message.data);
      final actionPayload = NotificationActionPayload.fromMap(
        message.data,
        title: message.notification?.title,
        body: message.notification?.body,
        notificationImageUrl: _extractImageUrl(message),
      );
      await _handleActionPayload(actionPayload);
      _onNotificationAction.add(actionPayload);
    });
  }

  /// Check if application was launched directly by clicking a notification
  Future<void> _checkInitialNotification() async {
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _onNotificationClick.add(initialMessage.data);
      final actionPayload = NotificationActionPayload.fromMap(
        initialMessage.data,
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        notificationImageUrl: _extractImageUrl(initialMessage),
      );
      await _handleActionPayload(actionPayload);
      _onNotificationAction.add(actionPayload);
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

  /// Displays a local notification on device with optional image URL and action parameters
  Future<void> showLocalNotification({
    int id = 0,
    required String title,
    required String body,
    String? imageUrl,
    String? payload,
    String? actionType,
    String? action,
    String? target,
  }) async {
    String? localImagePath;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      localImagePath = await _downloadAndSaveNotificationImage(
        imageUrl,
        'fg_notification_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    BigPictureStyleInformation? bigPictureStyle;
    if (localImagePath != null) {
      bigPictureStyle = BigPictureStyleInformation(
        FilePathAndroidBitmap(localImagePath),
        largeIcon: FilePathAndroidBitmap(localImagePath),
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: bigPictureStyle,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: localImagePath != null
          ? [DarwinNotificationAttachment(localImagePath)]
          : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    String finalPayload = payload ?? '';
    if (finalPayload.isEmpty) {
      final payloadMap = <String, dynamic>{
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (actionType != null) 'actionType': actionType,
        if (action != null) 'action': action,
        if (target != null) 'target': target,
      };
      finalPayload = jsonEncode(payloadMap);
    }

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: finalPayload,
    );
  }

  /// Get current device FCM Token
  Future<String?> getFcmToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null && kDebugMode) {
          AppLogger.w('APNS token is not available yet (common on simulator)');
        }
      }
      final token = await _fcm.getToken();
      if (token != null) {
        _fcmToken = token;
        AppLogger.i('FCM Registration Token generated: $token');
      }
      return token;
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching FCM Token', e, stackTrace);
      return null;
    }
  }

  void dispose() {
    _onTokenRefresh.close();
    _onNotificationClick.close();
    _onNotificationAction.close();
  }
}
