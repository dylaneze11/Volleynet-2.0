import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../models/match_model.dart';
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
  age: 24,
  gender: 'Hombre',
  pronoun: 'Él/Lo',
  league: 'Metropolitana',
  division: 'División de Honor',
  pastClubs: 'Boca Juniors (2020-2022)\nRiver Plate (2018-2020)',
  followersCount: 1240,
  followingCount: 156,
  bio: 'Apasionado por el vóley. Siempre buscando el siguiente remate. 🔥',
  createdAt: DateTime.now(),
);

final mockUserProvider = StateProvider<UserModel>((ref) => _mockUser);

// ─── Current User Profile ─────────────────────────────────────────────────────

final currentUserProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  // PREVIEW MODO: Ignorar auth y devolver usuario de prueba
  return Stream.value(ref.watch(mockUserProvider));
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
  return ref.watch(mockUserProvider);
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

// ─── Matches (Excel Table) ────────────────────────────────────────────────────

final matchesProvider = StateProvider<List<MatchModel>>((ref) {
  return [
    const MatchModel(
      id: 'mock_match_1',
      day: 'Sáb 15',
      time: '18:00',
      opponent: 'Club Estudiantes',
      location: 'Local',
      score: '',
    ),
    const MatchModel(
      id: 'mock_match_2',
      day: 'Sáb 22',
      time: '19:30',
      opponent: 'Vélez Sarsfield',
      location: 'Visitante',
      score: '3 - 0',
    ),
  ];
});
