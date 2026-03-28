// Data Models for VolleyNet

import 'package:cloud_firestore/cloud_firestore.dart';

// ─── User Model ───────────────────────────────────────────────────────────────

enum UserRole { player, coach, club }

enum PlayerPosition { setter, libero, outside, middle, opposite }

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final UserRole role;
  final int followersCount;
  final int followingCount;
  final List<String> followers;
  final List<String> following;

  // Player-specific
  final PlayerPosition? position;
  final double? height;
  final String? handedness;   // 'Diestro' | 'Zurdo'
  final String? category;     // 'Mini' | 'Infantil' | 'Cadete' | 'Junior' | 'Mayor'
  final String? nationality;

  // Coach-specific
  final String? certificationLevel;
  final int? yearsExperience;
  final List<String>? coachedCategories;

  // Club-specific
  final String? location;
  final String? city;
  final String? country;
  final String? trainingDays;
  final List<String>? federatedCategories;

  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    required this.role,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers = const [],
    this.following = const [],
    this.position,
    this.height,
    this.handedness,
    this.category,
    this.nationality,
    this.certificationLevel,
    this.yearsExperience,
    this.coachedCategories,
    this.location,
    this.city,
    this.country,
    this.trainingDays,
    this.federatedCategories,
    required this.createdAt,
  });

  static UserRole _roleFromString(String s) {
    switch (s) {
      case 'coach': return UserRole.coach;
      case 'club': return UserRole.club;
      default: return UserRole.player;
    }
  }

  static PlayerPosition? _positionFromString(String? s) {
    if (s == null) return null;
    switch (s) {
      case 'setter': return PlayerPosition.setter;
      case 'libero': return PlayerPosition.libero;
      case 'outside': return PlayerPosition.outside;
      case 'middle': return PlayerPosition.middle;
      case 'opposite': return PlayerPosition.opposite;
      default: return null;
    }
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      bio: data['bio'],
      role: _roleFromString(data['role'] ?? 'player'),
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      position: _positionFromString(data['position']),
      height: (data['height'] as num?)?.toDouble(),
      handedness: data['handedness'],
      category: data['category'],
      nationality: data['nationality'],
      certificationLevel: data['certificationLevel'],
      yearsExperience: data['yearsExperience'],
      coachedCategories: data['coachedCategories'] != null
          ? List<String>.from(data['coachedCategories'])
          : null,
      location: data['location'],
      city: data['city'],
      country: data['country'],
      trainingDays: data['trainingDays'],
      federatedCategories: data['federatedCategories'] != null
          ? List<String>.from(data['federatedCategories'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'role': role.name,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'followers': followers,
      'following': following,
      'position': position?.name,
      'height': height,
      'handedness': handedness,
      'category': category,
      'nationality': nationality,
      'certificationLevel': certificationLevel,
      'yearsExperience': yearsExperience,
      'coachedCategories': coachedCategories,
      'location': location,
      'city': city,
      'country': country,
      'trainingDays': trainingDays,
      'federatedCategories': federatedCategories,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    int? followersCount,
    int? followingCount,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      role: role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      position: position,
      height: height,
      handedness: handedness,
      category: category,
      nationality: nationality,
      certificationLevel: certificationLevel,
      yearsExperience: yearsExperience,
      coachedCategories: coachedCategories,
      location: location,
      city: city,
      country: country,
      trainingDays: trainingDays,
      federatedCategories: federatedCategories,
      createdAt: createdAt,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.player: return 'Jugador/a';
      case UserRole.coach: return 'Entrenador/a';
      case UserRole.club: return 'Club';
    }
  }

  String get positionLabel {
    switch (position) {
      case PlayerPosition.setter: return 'Armador/a';
      case PlayerPosition.libero: return 'Líbero';
      case PlayerPosition.outside: return 'Punta';
      case PlayerPosition.middle: return 'Central';
      case PlayerPosition.opposite: return 'Opuesto/a';
      case null: return '';
    }
  }
}

// ─── Post Model ───────────────────────────────────────────────────────────────

enum PostTag {
  soloContenido,
  buscoClub,
  buscoJugador,
  buscoEntrenador,
}

class PostModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String? authorRole;
  final String mediaUrl;
  final String mediaType; // 'photo' | 'video'
  final String? caption;
  final List<PostTag> tags;
  final int likeCount;
  final int commentCount;
  final List<String> likedBy;
  final String? location;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    this.authorRole,
    required this.mediaUrl,
    this.mediaType = 'photo',
    this.caption,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedBy = const [],
    this.location,
    required this.createdAt,
  });

  static PostTag _tagFromString(String s) {
    switch (s) {
      case 'BuscoClub': return PostTag.buscoClub;
      case 'BuscoJugador': return PostTag.buscoJugador;
      case 'BuscoEntrenador': return PostTag.buscoEntrenador;
      default: return PostTag.soloContenido;
    }
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      authorRole: data['authorRole'],
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'photo',
      caption: data['caption'],
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((t) => _tagFromString(t as String))
          .toList(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'tags': tags.map((t) => t.label).toList(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likedBy': likedBy,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool isLikedBy(String uid) => likedBy.contains(uid);

  PostModel copyWith({int? likeCount, List<String>? likedBy, int? commentCount}) {
    return PostModel(
      id: id,
      authorUid: authorUid,
      authorName: authorName,
      authorPhotoUrl: authorPhotoUrl,
      authorRole: authorRole,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedBy: likedBy ?? this.likedBy,
      location: location,
      createdAt: createdAt,
    );
  }
}

extension PostTagExtension on PostTag {
  String get label {
    switch (this) {
      case PostTag.soloContenido: return 'SoloContenido';
      case PostTag.buscoClub: return 'BuscoClub';
      case PostTag.buscoJugador: return 'BuscoJugador';
      case PostTag.buscoEntrenador: return 'BuscoEntrenador';
    }
  }

  String get displayLabel {
    switch (this) {
      case PostTag.soloContenido: return '#SoloContenido';
      case PostTag.buscoClub: return '#BuscoClub';
      case PostTag.buscoJugador: return '#BuscoJugador';
      case PostTag.buscoEntrenador: return '#BuscoEntrenador';
    }
  }
}

// ─── Comment Model ────────────────────────────────────────────────────────────

class CommentModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String text;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// ─── Message / Chat Models ────────────────────────────────────────────────────

class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantPhotos,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
      participantPhotos: Map<String, String?>.from(data['participantPhotos'] ?? {}),
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
