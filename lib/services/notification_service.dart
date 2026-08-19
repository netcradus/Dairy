import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents an incoming order-related push alert.
class OrderAlert {
  const OrderAlert({
    required this.orderId,
    this.title,
    this.body,
    this.data = const {},
  });

  final String orderId;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
}

/// Holds the most recent order alert so the UI can react (e.g. show a banner
/// or refresh the orders list) when a notification arrives.
final orderAlertProvider = StateProvider<OrderAlert?>((ref) => null);

/// Background message handler. Must be a top-level function (not a closure) and
/// must be annotated so it survives tree-shaking. It is invoked when a message
/// arrives while the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Order alerts received here are already displayed by the system notification
  // tray. Add any background-only processing (e.g. writing to local storage or
  // updating a badge count) in this method. UI updates are handled by the
  // foreground listener in [NotificationService].
}

/// Wraps Firebase Cloud Messaging and local notifications: requests permission,
/// initializes the local notification channel, and routes incoming order alerts
/// to both a local notification and the [orderAlertProvider] for the UI.
class NotificationService {
  NotificationService(this._ref);

  final Ref _ref;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'order_alerts',
    'Order Alerts',
    description: 'Notifications for new and updated orders',
    importance: Importance.high,
  );

  /// Initializes local notifications, requests permission, and wires up the
  /// foreground / opened-app message listeners.
  Future<void> init() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await requestPermission();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);
  }

  /// Requests notification permission for iOS, Android (13+) and Web.
  Future<NotificationSettings> requestPermission() async {
    return _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// The current FCM registration token. Send this to your backend so it can
  /// target this device when sending order alerts.
  Future<String?> getToken() => _messaging.getToken();

  /// Stream of token refreshes (re-upload to your backend on change).
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  void _onForegroundMessage(RemoteMessage message) {
    _showLocalNotification(message);
    _pushOrderAlert(message);
  }

  void _onOpenedApp(RemoteMessage message) {
    _pushOrderAlert(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: _channel.importance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.toString(),
    );
  }

  void _pushOrderAlert(RemoteMessage message) {
    final orderId = message.data['orderId'] ?? message.data['order_id'];
    if (orderId == null) return;

    _ref.read(orderAlertProvider.notifier).state = OrderAlert(
      orderId: orderId.toString(),
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
    );
  }
}

/// Provides the [NotificationService], bound to the Riverpod container.
final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService(ref));

/// Triggers one-time initialization of notifications (permission + listeners).
/// Watch this from the app root (see [MyApp]) so it runs exactly once.
final notificationInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.init();
});
