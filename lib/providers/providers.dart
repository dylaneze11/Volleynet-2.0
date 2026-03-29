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
  return ref.watch(postRepositoryProvider).getFeedPosts();
});

// ─── Free Agents ──────────────────────────────────────────────────────────────

final freeAgentsProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return Stream.value([
    UserModel(
      uid: 'free_1',
      displayName: "MARCOS 'EL MURO' RUIZ",
      email: 'muro@example.com',
      role: UserRole.player,
      position: PlayerPosition.middle,
      height: 210,
      age: 31,
      category: 'Libre',
      photoUrl: "https://images.unsplash.com/photo-1593341398860-264627b1406c?q=80&w=600",
      createdAt: DateTime.now(),
    ),
    UserModel(
      uid: 'free_2',
      displayName: "LUCÍA FERNANDEZ",
      email: 'lucia@example.com',
      role: UserRole.player,
      position: PlayerPosition.opposite,
      height: 188,
      age: 24,
      category: 'Libre',
      photoUrl: "https://images.unsplash.com/photo-1574629810360-7efbc5ea002c?q=80&w=600",
      createdAt: DateTime.now(),
    ),
    UserModel(
      uid: 'free_3',
      displayName: "JUAN CRUZ",
      email: 'juan@example.com',
      role: UserRole.player,
      position: PlayerPosition.outside,
      height: 195,
      age: 21,
      category: 'Libre',
      photoUrl: "https://images.unsplash.com/photo-1620986794691-30a84e6db614?q=80&w=600",
      createdAt: DateTime.now(),
    ),
  ]);
});

// ─── Market Filter ────────────────────────────────────────────────────────────

final marketFilterProvider = StateProvider<List<String>>((ref) => []);

final marketPostsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  final tags = ref.watch(marketFilterProvider);
  return ref.watch(postRepositoryProvider).getMarketPosts(tags: tags);
});

// ─── User Posts ───────────────────────────────────────────────────────────────

final userPostsProvider = StreamProvider.autoDispose.family<List<PostModel>, String>((ref, uid) {
  return ref.watch(postRepositoryProvider).getUserPosts(uid);
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
  return ref.watch(postRepositoryProvider).getComments(postId);
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
