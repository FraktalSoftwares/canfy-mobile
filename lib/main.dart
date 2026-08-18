import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'constants/supabase_config.dart';
import 'services/push/push_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // Inicializar Supabase
  // IMPORTANTE: A chave anônima deve ser configurada em SupabaseConfig
  if (!SupabaseConfig.isConfigured) {
    throw Exception(
      'Chave anônima do Supabase não configurada!\n'
      'Configure em lib/constants/supabase_config.dart\n'
      'Obtenha a chave em: https://supabase.com/dashboard/project/agqqxxfrnpuriwrmwdrq/settings/api'
    );
  }

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Push (FCM/APNs) é opcional: sem google-services.json/GoogleService-Info.plist
  // configurados nativamente, Firebase.initializeApp() lança e o app segue
  // funcionando normalmente sem push, como qualquer outra integração externa
  // não configurada neste projeto.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushService.instance.init();
  } catch (e) {
    debugPrint('Push notifications não configuradas: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Canfy Mobile',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('pt', 'BR'),
            ],
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
