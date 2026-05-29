import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/models.dart';
import 'providers.dart';

// ─── Feed Status ──────────────────────────────────────────────────────────────

enum FeedStatus {
  initializing,
  emptyNotFollowing,
  emptyFollowingNoPosts,
  data,
  error,
}

class FeedState {
  final FeedStatus status;
  final List<PostModel> posts;
  final String? error;

  const FeedState({
    this.status = FeedStatus.initializing,
    this.posts = const [],
    this.error,
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

List<List<T>> _chunk<T>(List<T> list, int size) {
  final chunks = <List<T>>[];
  for (var i = 0; i < list.length; i += size) {
    chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
  }
  return chunks;
}

// ─── Following IDs Stream ─────────────────────────────────────────────────────

final followingIdsProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final currentUser = ref.watch(currentUserProvider).valueOrNull;
  if (currentUser == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .snapshots()
      .map((doc) => List<String>.from(doc.data()?['following'] ?? []));
});

// ─── Feed State Provider ──────────────────────────────────────────────────────

final feedStateProvider = StreamProvider.autoDispose<FeedState>((ref) {
  final followingAsync = ref.watch(followingIdsProvider);
  final followingIds = followingAsync.valueOrNull ?? [];

  if (followingAsync.isLoading) {
    return Stream.value(const FeedState(status: FeedStatus.initializing));
  }

  if (followingIds.isEmpty) {
    return Stream.value(const FeedState(status: FeedStatus.emptyNotFollowing));
  }

  final postRepo = ref.watch(postRepositoryProvider);
  final chunks = _chunk(followingIds, 30);

  // Each chunk queries posts where authorId in chunk
  final streams = chunks.map((chunk) =>
    postRepo.getFeedPostsChunk(chunk, limit: 50)
  );

  if (streams.isEmpty) {
    return Stream.value(const FeedState(status: FeedStatus.emptyFollowingNoPosts));
  }

  // Merge all chunk streams, combine latest values, sort by timestamp
  return Rx.combineLatestList(streams).map((listOfLists) {
    final merged = listOfLists.expand((l) => l).toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (merged.isEmpty) {
      return const FeedState(status: FeedStatus.emptyFollowingNoPosts);
    }
    return FeedState(status: FeedStatus.data, posts: merged);
  }).handleError((err) {
    return FeedState(status: FeedStatus.error, error: err.toString());
  });
});
