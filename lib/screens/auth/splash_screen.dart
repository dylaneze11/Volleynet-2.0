import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (_, next) {
      next.whenData((user) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (context.mounted) {
            if (user != null) {
              context.go('/home');
            } else {
              context.go('/auth/login');
            }
          }
        });
      });
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.sports_volleyball, color: Colors.white, size: 52),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'VolleyNet',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.3),
            const SizedBox(height: 8),
            Text(
              'La red del voleibol',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 60),
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
