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
        apiKey: 'AIzaSyCKAaxDOFmnxoRq-HmjdZfUOt-usdjUQ1Q',
        appId: '1:165577824935:web:e4077a282d8f0c1ea41982',
        messagingSenderId: '165577824935',
        projectId: 'volleynet-b13f6',
        storageBucket: 'volleynet-b13f6.firebasestorage.app',
        authDomain: 'volleynet-b13f6.firebaseapp.com',
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
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      builder: (context, child) {
        return Container(
          color: const Color(0xFFE5E7EB), // Gray background outside the app bounds
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
