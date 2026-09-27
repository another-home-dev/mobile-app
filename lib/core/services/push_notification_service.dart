import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../network/services/notifications_api_service.dart';

/// Registers this device for real, OS-level push notifications (a banner even
/// with the app closed) for visitor approvals, resolved maintenance tickets,
/// and payment reminders/receipts.
///
/// Firebase must be configured (android/app/google-services.json present) for
/// any of this to work; every method below fails silently if it isn't, so a
/// build without Firebase set up still runs — it just has no push, the same
/// as before this feature existed.
class PushNotificationService {
  final NotificationsApiService _notificationsApiService;

  PushNotificationService(this._notificationsApiService);

  bool _initialized = false;

  /// Call once, right after the student's id is known (e.g. after login).
  /// Safe to call again later — Firebase.initializeApp() is a no-op if it's
  /// already been called, and re-registering the same token is harmless.
  Future<void> init(String userId) async {
    try {
      if (!_initialized) {
        await Firebase.initializeApp();
        _initialized = true;
      }

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      if (token != null) {
        await _notificationsApiService.registerDeviceToken(userId, token);
      }

      // FCM can reissue a token (e.g. after a reinstall); keep the backend in sync.
      messaging.onTokenRefresh.listen((newToken) {
        _notificationsApiService.registerDeviceToken(userId, newToken);
      });
    } catch (_) {
      // No Firebase project configured yet, or the device has no Google
      // Play services — the app keeps working with in-app alerts only.
    }
  }
}
