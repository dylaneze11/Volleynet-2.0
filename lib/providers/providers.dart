import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// ─── Repository Providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final postRepositoryProvider = Provider<PostRepository>((ref) => PostRepository());
final messageRepositoryProvider = Provider<MessageRepository>((ref) => MessageRepository());

// ─── Auth State ───────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ─── Current User Profile ─────────────────────────────────────────────────────

final currentUserProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(auth.uid);
});

// ─── Feed Posts ───────────────────────────────────────────────────────────────

final feedPostsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  return ref.watch(postRepositoryProvider).getFeedPosts();
});

// ─── Market Posts ─────────────────────────────────────────────────────────────

final marketFilterProvider = StateProvider<List<String>>((ref) => []);

final marketPostsProvider = StreamProvider.autoDispose<List<PostModel>>((ref) {
  final tags = ref.watch(marketFilterProvider);
  return ref.watch(postRepositoryProvider).getMarketPosts(tags: tags.isEmpty ? null : tags);
});

// ─── User Posts ───────────────────────────────────────────────────────────────

final userPostsProvider = StreamProvider.autoDispose.family<List<PostModel>, String>((ref, uid) {
  return ref.watch(postRepositoryProvider).getUserPosts(uid);
});

// ─── User Profile ─────────────────────────────────────────────────────────────

final userProfileProvider = FutureProvider.autoDispose.family<UserModel?, String>((ref, uid) {
  return ref.watch(userRepositoryProvider).getUserById(uid);
});

// ─── Conversations ────────────────────────────────────────────────────────────

final conversationsProvider = StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  if (auth == null) return Stream.value([]);
  return ref.watch(messageRepositoryProvider).getConversations(auth.uid);
});

// ─── Messages ─────────────────────────────────────────────────────────────────

final messagesProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, convId) {
  return ref.watch(messageRepositoryProvider).getMessages(convId);
});

// ─── Comments ─────────────────────────────────────────────────────────────────

final commentsProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, postId) {
  return ref.watch(postRepositoryProvider).getComments(postId);
});
