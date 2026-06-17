import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class FcmService {
  final ApiService _apiService;
  HubConnection? _hubConnection;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  FcmService(this._apiService);

  bool _isInitialized = false;

  static VoidCallback? onRefreshRequired;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get token
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          debugPrint("FCM Token: $token");
          await _apiService.updateFcmToken(token);
        }

        // Setup local notifications for foreground display
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosInit = DarwinInitializationSettings();
        const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
        await _localNotifications.initialize(settings: initSettings);

        // Listen to foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null) {
            _showLocalNotification(message.notification!.title, message.notification!.body);
            if (onRefreshRequired != null) onRefreshRequired!();
          }
        });

        // Listen to token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          _apiService.updateFcmToken(newToken);
        });
      }

      await _connectSignalR();
      _isInitialized = true;
    } catch (e) {
      debugPrint("FCM initialization error: $e");
    }
  }

  Future<void> _connectSignalR() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return;

      final baseUrl = ApiConstants.apiUrl.replaceAll('/api', '');
      final hubUrl = '$baseUrl/notificationHub';

      _hubConnection = HubConnectionBuilder()
          .withUrl(hubUrl, options: HttpConnectionOptions(
            accessTokenFactory: () async => token,
          ))
          .withAutomaticReconnect()
          .build();

      _hubConnection?.on('ReceiveNotification', (arguments) {
        if (arguments != null && arguments.isNotEmpty) {
          final data = arguments[0] as Map<String, dynamic>;
          final title = data['title']?.toString();
          final body = data['body']?.toString();
          _showLocalNotification(title, body);
          if (onRefreshRequired != null) onRefreshRequired!();
        }
      });

      _hubConnection?.on('RefreshData', (arguments) {
        if (onRefreshRequired != null) onRefreshRequired!();
      });

      await _hubConnection?.start();
      debugPrint("SignalR connected.");
    } catch (e) {
      debugPrint("SignalR connection error: $e");
    }
  }

  Future<void> disconnect() async {
    await _hubConnection?.stop();
    _hubConnection = null;
  }

  Future<void> _showLocalNotification(String? title, String? body) async {
    if (title == null && body == null) return;

    const androidDetails = AndroidNotificationDetails(
      'famihub_channel',
      'FamiHub Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
