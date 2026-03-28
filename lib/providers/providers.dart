import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// ─── Repository Providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final postRepositoryProvider = Provider<PostRepository>((ref) => PostRepository());
final messageRepositoryProvider = Provider<MessageRepository>((ref) => MessageRepository());

// ─── Development Mock Data ──────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return Stream.value(null); // Mock auth state
});

final _mockUser = UserModel(
  uid: 'preview_user',
  displayName: 'Dylan Ezequiel',
  email: 'dylan@volleynet.com',
  role: UserRole.player,
  position: PlayerPosition.outside,
  height: 185,
  handedness: 'Diestro',
  category: 'Mayores',
  followersCount: 1240,
  followingCount: 156,
  bio: 'Apasionado por el vóley. Siempre buscando el siguiente remate. 🔥',
  createdAt: DateTime.now(),
);

// ─── Current User Profile ─────────────────────────────────────────────────────

final currentUserProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  // PREVIEW MODO: Ignorar auth y devolver usuario de prueba
  return Stream.value(_mockUser);
});

// ─── Feed Posts ───────────────────────────────────────────────────────────────

final feedPostsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  // Devolvemos lista vacía para mostrar el "Empty State" bonito
  return Stream.value([]);
});

// ─── Market Posts ─────────────────────────────────────────────────────────────

final marketFilterProvider = StateProvider<List<String>>((ref) => []);

final marketPostsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  return Stream.value([]);
});

// ─── User Posts ───────────────────────────────────────────────────────────────

final userPostsProvider = StreamProvider.autoDispose.family<List<PostModel>, String>((ref, uid) {
  return Stream.value([]);
});

// ─── User Profile ─────────────────────────────────────────────────────────────

final userProfileProvider = FutureProvider.autoDispose.family<UserModel?, String>((ref, uid) async {
  return _mockUser;
});

// ─── Conversations ────────────────────────────────────────────────────────────

final conversationsProvider = StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  return Stream.value([]);
});

// ─── Messages ─────────────────────────────────────────────────────────────────

final messagesProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, convId) {
  return Stream.value([]);
});

// ─── Comments ─────────────────────────────────────────────────────────────────

final commentsProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, postId) {
  return Stream.value([]);
});
