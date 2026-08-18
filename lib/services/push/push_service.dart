import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/router/app_router.dart';

/// Registro de token FCM/APNs e navegação ao tocar numa push notification.
///
/// Sem projeto Firebase configurado nativamente (google-services.json /
/// GoogleService-Info.plist ausentes), `Firebase.initializeApp()` falha antes
/// de chegar aqui — ver o try/catch em main.dart. Com o projeto configurado
/// mas sem FIREBASE_SERVICE_ACCOUNT_JSON na Edge Function `enviar-push`, o
/// token é registrado normalmente, só o envio do lado do servidor vira no-op.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleTap(initialMessage);
    }

    messaging.onTokenRefresh.listen((_) => _registerToken());

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.tokenRefreshed:
          _registerToken();
          break;
        case AuthChangeEvent.signedOut:
          _unregisterCurrentToken();
          break;
        default:
          break;
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      await _registerToken();
    }
  }

  Future<void> _registerToken() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      final plataforma =
          defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
      await Supabase.instance.client.from('push_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'plataforma': plataforma,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
    } catch (_) {
      // Push é opcional — falha ao registrar token nunca deve travar o app.
    }
  }

  Future<void> _unregisterCurrentToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await Supabase.instance.client.from('push_tokens').delete().eq('token', token);
    } catch (_) {}
  }

  void _handleTap(RemoteMessage message) {
    final rota = message.data['rota'] as String?;
    if (rota == null || rota.isEmpty) return;
    AppRouter.router.go(rota);
  }
}

/// Handler de background exigido pelo firebase_messaging — precisa ser uma
/// função top-level (não método de classe) e registrada antes do runApp.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Sem trabalho a fazer aqui: o SO já exibe a notificação do sistema a
  // partir do payload `notification`. O toque é tratado em _handleTap.
}
