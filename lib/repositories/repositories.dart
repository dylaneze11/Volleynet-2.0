import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

// ─── Auth Repository ──────────────────────────────────────────────────────────

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password, [String? name]) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (name != null && name.isNotEmpty) {
      await cred.user?.updateDisplayName(name);
      
      // Intentar crear un perfil base en Firestore aquí para que no falle luego
      try {
        await createUserProfile(UserModel(
          uid: cred.user!.uid,
          email: email,
          displayName: name,
          bio: 'Nuevo Jugador',
          role: UserRole.player,
          createdAt: DateTime.now(),
        ));
      } catch (_) {}
    }
    return cred;
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }
}

// ─── User Repository ──────────────────────────────────────────────────────────

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        return UserModel(
          uid: uid,
          email: currentUser.email ?? '',
          displayName: currentUser.displayName ?? 'Usuario Nuevo',
          role: UserRole.player,
          createdAt: DateTime.now(),
        );
      }
      return null;
    }
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
      (doc) {
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.uid == uid) {
            return UserModel(
              uid: uid,
              email: currentUser.email ?? '',
              displayName: currentUser.displayName ?? 'Usuario Nuevo',
              role: UserRole.player,
              createdAt: DateTime.now(),
            );
          }
          return null;
        }
      }
    );
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  Future<String> uploadAvatar(String uid, Uint8List imageBytes) async {
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<void> followUser(String currentUid, String targetUid) async {
    final batch = _firestore.batch();
    final currentRef = _firestore.collection('users').doc(currentUid);
    final targetRef = _firestore.collection('users').doc(targetUid);
    batch.update(currentRef, {
      'following': FieldValue.arrayUnion([targetUid]),
      'followingCount': FieldValue.increment(1),
    });
    batch.update(targetRef, {
      'followers': FieldValue.arrayUnion([currentUid]),
      'followersCount': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> unfollowUser(String currentUid, String targetUid) async {
    final batch = _firestore.batch();
    final currentRef = _firestore.collection('users').doc(currentUid);
    final targetRef = _firestore.collection('users').doc(targetUid);
    batch.update(currentRef, {
      'following': FieldValue.arrayRemove([targetUid]),
      'followingCount': FieldValue.increment(-1),
    });
    batch.update(targetRef, {
      'followers': FieldValue.arrayRemove([currentUid]),
      'followersCount': FieldValue.increment(-1),
    });
    // Delete follows doc if exists
    final followsId = '${currentUid}_${targetUid}';
    batch.delete(_firestore.collection('follows').doc(followsId));
    await batch.commit();
  }

  /// Get suggested users based on same location, excluding self and already followed.
  Future<List<UserModel>> getSuggestedUsers(String currentUid, List<String> alreadyFollowing, {String? location, String? province, UserRole? role}) async {
    final results = <UserModel>{};
    final excludeIds = {...alreadyFollowing, currentUid};

    // 1. Try by exact location (city)
    if (location != null && location.isNotEmpty) {
      final snap = await _firestore
          .collection('users')
          .where('city', isEqualTo: location)
          .limit(20)
          .get();
      for (var doc in snap.docs) {
        if (!excludeIds.contains(doc.id)) {
          results.add(UserModel.fromFirestore(doc));
        }
      }
    }

    // 2. If < 5, broaden to province
    if (results.length < 5 && province != null && province.isNotEmpty) {
      final snap = await _firestore
          .collection('users')
          .where('province', isEqualTo: province)
          .limit(30)
          .get();
      for (var doc in snap.docs) {
        if (!excludeIds.contains(doc.id)) {
          results.add(UserModel.fromFirestore(doc));
        }
      }
    }

    // 3. If still < 5, get recent users as fallback
    if (results.length < 5) {
      final snap = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      for (var doc in snap.docs) {
        if (!excludeIds.contains(doc.id)) {
          results.add(UserModel.fromFirestore(doc));
        }
      }
    }

    // Sort: same role first, then others
    final list = results.toList();
    if (role != null) {
      list.sort((a, b) {
        if (a.role == role && b.role != role) return -1;
        if (a.role != role && b.role == role) return 1;
        return 0;
      });
    }

    return list.take(20).toList();
  }

  /// Batch follow multiple users (used in onboarding)
  Future<void> batchFollowUsers(String currentUid, List<String> targetUids) async {
    if (targetUids.isEmpty) return;
    final batch = _firestore.batch();
    final currentRef = _firestore.collection('users').doc(currentUid);

    batch.update(currentRef, {
      'following': FieldValue.arrayUnion(targetUids),
      'followingCount': FieldValue.increment(targetUids.length),
    });

    for (final targetUid in targetUids) {
      final targetRef = _firestore.collection('users').doc(targetUid);
      batch.update(targetRef, {
        'followers': FieldValue.arrayUnion([currentUid]),
        'followersCount': FieldValue.increment(1),
      });
      final followsId = '${currentUid}_$targetUid';
      batch.set(_firestore.collection('follows').doc(followsId), {
        'followerId': currentUid,
        'followedId': targetUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

// ─── Post Repository ──────────────────────────────────────────────────────────

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<PostModel>> getFeedPosts({DocumentSnapshot? lastDoc, int limit = 10, List<String>? following}) {
    Query query = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit);
        
    if (following != null && following.isNotEmpty) {
      final queryList = following.length > 30 ? following.sublist(0, 30) : following;
      query = query.where('authorUid', whereIn: queryList);
    }
    
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => PostModel.fromFirestore(d)).toList(),
    );
  }

  /// Feed query for a chunk of following IDs (max 30 per chunk).
  Stream<List<PostModel>> getFeedPostsChunk(List<String> followingChunk, {int limit = 50}) {
    return _firestore
        .collection('posts')
        .where('authorUid', whereIn: followingChunk)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => PostModel.fromFirestore(d)).toList());
  }

  /// Paginated: fetch next page of posts from a chunk.
  Future<List<PostModel>> getNextFeedPostsChunk(List<String> followingChunk, DocumentSnapshot lastDoc, {int limit = 20}) async {
    final snap = await _firestore
        .collection('posts')
        .where('authorUid', whereIn: followingChunk)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
    return snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
  }

  Stream<List<PostModel>> getMarketPosts({List<String>? tags, String? position, String? city}) {
    Query query = _firestore.collection('posts');
    if (tags != null && tags.isNotEmpty) {
      query = query.where('tags', arrayContainsAny: tags);
    } else {
      query = query.where('tags', arrayContainsAny: ['BuscoClub', 'BuscoJugador', 'BuscoEntrenador']);
    }
    return query.snapshots().map((snap) {
      final posts = snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return _firestore
        .collection('posts')
        .where('authorUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final posts = snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  Future<String> uploadPostMedia(String uid, Uint8List bytes, String type) async {
    final String ext = type == 'video' ? 'mp4' : 'jpg';
    final String fileName = '${const Uuid().v4()}.$ext';
    final ref = _storage.ref('posts/$uid/$fileName');
    await ref.putData(bytes, SettableMetadata(contentType: type == 'video' ? 'video/mp4' : 'image/jpeg'));
    return await ref.getDownloadURL();
  }

  Future<String> createPost(PostModel post) async {
    final ref = await _firestore.collection('posts').add(post.toFirestore());
    return ref.id;
  }

  Future<void> deletePost(String postId) async {
    // Primero intentamos borrar los comentarios asociados para que no queden huérfanos
    final commentsSnap = await _firestore.collection('posts').doc(postId).collection('comments').get();
    final batch = _firestore.batch();
    for (var doc in commentsSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Luego borramos el post
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> toggleLike(String postId, String uid) async {
    final ref = _firestore.collection('posts').doc(postId);
    final doc = await ref.get();
    final likedBy = List<String>.from((doc.data() as Map)['likedBy'] ?? []);
    if (likedBy.contains(uid)) {
      await ref.update({
        'likedBy': FieldValue.arrayRemove([uid]),
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      await ref.update({
        'likedBy': FieldValue.arrayUnion([uid]),
        'likeCount': FieldValue.increment(1),
      });
    }
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => CommentModel.fromFirestore(d)).toList());
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    final batch = _firestore.batch();
    final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc();
    batch.set(commentRef, comment.toFirestore());
    batch.update(_firestore.collection('posts').doc(postId), {
      'commentCount': FieldValue.increment(1),
    });
    await batch.commit();
  }
}

// ─── Message Repository ───────────────────────────────────────────────────────

class MessageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ConversationModel>> getConversations(String uid) {
    return _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: uid)
        .snapshots()
        .map((snap) {
          final convs = snap.docs.map((d) => ConversationModel.fromFirestore(d)).toList();
          convs.sort((a, b) {
            final aAt = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bAt = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bAt.compareTo(aAt);
          });
          return convs;
        });
  }

  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MessageModel.fromFirestore(d)).toList());
  }

  Future<String> getOrCreateConversation(UserModel currentUser, UserModel otherUser) async {
    final ids = [currentUser.uid, otherUser.uid]..sort();
    final convId = ids.join('_');
    final ref = _firestore.collection('conversations').doc(convId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'participantIds': ids,
        'participantNames': {
          currentUser.uid: currentUser.displayName,
          otherUser.uid: otherUser.displayName,
        },
        'participantPhotos': {
          currentUser.uid: currentUser.photoUrl,
          otherUser.uid: otherUser.photoUrl,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }
    return convId;
  }

  Future<void> sendMessage(String conversationId, MessageModel message) async {
    final batch = _firestore.batch();
    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch.set(msgRef, message.toFirestore());
    batch.update(_firestore.collection('conversations').doc(conversationId), {
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': message.senderId,
    });
    await batch.commit();
  }
}
