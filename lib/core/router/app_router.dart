import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_step1_screen.dart';
import '../../screens/auth/register_step2_screen.dart';
import '../../screens/shell/app_shell.dart';
import '../../screens/feed/feed_screen.dart';
import '../../screens/market/market_screen.dart';
import '../../screens/upload/upload_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/messages/conversations_screen.dart';
import '../../screens/messages/chat_screen.dart';
import '../../screens/matches/matches_screen.dart';
import '../../models/models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // TEMPORAL: Permite navegación libre para probar la UI
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterStep1Screen(),
      ),
      GoRoute(
        path: '/auth/register/details',
        builder: (context, state) {
          final role = state.extra as UserRole;
          return RegisterStep2Screen(role: role);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const FeedScreen(),
          ),
          GoRoute(
            path: '/market',
            builder: (context, state) => const MarketScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/profile/:uid',
            builder: (context, state) {
              final uid = state.pathParameters['uid']!;
              return ProfileScreen(uid: uid);
            },
          ),
          // Moved messages out of ShellRoute
        ],
      ),
      GoRoute(
        path: '/messages',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/messages/:conversationId',
        builder: (context, state) {
          final convId = state.pathParameters['conversationId']!;
          final otherUser = state.extra as UserModel;
          return ChatScreen(conversationId: convId, otherUser: otherUser);
        },
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MatchesScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
