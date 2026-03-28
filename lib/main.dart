import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
// import 'firebase_options.dart'; // Uncomment after running: flutterfire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  // ⚠️ IMPORTANT: Run `flutterfire configure` first to generate firebase_options.dart
  // Then uncomment the line below:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Temporary: initialize without options for UI preview (remove once Firebase is configured)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'REPLACE_WITH_YOUR_API_KEY',
        appId: 'REPLACE_WITH_YOUR_APP_ID',
        messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
        projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
        storageBucket: 'REPLACE_WITH_YOUR_BUCKET',
        authDomain: 'REPLACE_WITH_YOUR_AUTH_DOMAIN',
      ),
    );
  } catch (e) {
    // Already initialized or config missing — OK for dev preview
    debugPrint('Firebase init: $e');
  }

  // timeago Spanish locale
  timeago.setLocaleMessages('es', timeago.EsMessages());

  runApp(
    const ProviderScope(
      child: VolleyNetApp(),
    ),
  );
}

class VolleyNetApp extends ConsumerWidget {
  const VolleyNetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VolleyNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
