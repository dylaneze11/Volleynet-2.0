// Data Models for VolleyNet

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── User Model ───────────────────────────────────────────────────────────────

enum UserRole { player, coach, club }

enum PlayerPosition { setter, libero, outside, middle, opposite }

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final Uint8List? localPhotoBytes;
  final String? bio;
  final UserRole role;
  final int followersCount;
  final int followingCount;
  final List<String> followers;
  final List<String> following;
  final List<String> interests;

  // Player-specific
  final PlayerPosition? position;
  final double? height;
  final String? handedness;   // 'Diestro' | 'Zurdo'
  final String? category;     // 'Mini' | 'Infantil' | 'Cadete' | 'Junior' | 'Mayor'
  final String? nationality;
  final String? pronoun;
  final String? gender;
  final int? age;
  final String? pastClubs;
  final String? division;
  final String? league;

  // Coach-specific
  final String? certificationLevel;
  final int? yearsExperience;
  final List<String>? coachedCategories;

  // Club-specific
  final String? location;
  final String? city;
  final String? province;
  final String? country;
  final String? trainingDays;
  final List<String>? federatedCategories;

  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.localPhotoBytes,
    this.bio,
    required this.role,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers = const [],
    this.following = const [],
    this.interests = const [],
    this.position,
    this.height,
    this.handedness,
    this.category,
    this.nationality,
    this.pronoun,
    this.gender,
    this.age,
    this.pastClubs,
    this.division,
    this.league,
    this.certificationLevel,
    this.yearsExperience,
    this.coachedCategories,
    this.location,
    this.city,
    this.province,
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
      interests: List<String>.from(data['interests'] ?? []),
      position: _positionFromString(data['position']),
      height: (data['height'] as num?)?.toDouble(),
      handedness: data['handedness'],
      category: data['category'],
      nationality: data['nationality'],
      pronoun: data['pronoun'],
      gender: data['gender'],
      age: data['age'],
      pastClubs: data['pastClubs'],
      division: data['division'],
      league: data['league'],
      certificationLevel: data['certificationLevel'],
      yearsExperience: data['yearsExperience'],
      coachedCategories: data['coachedCategories'] != null
          ? List<String>.from(data['coachedCategories'])
          : null,
      location: data['location'],
      city: data['city'],
      province: data['province'],
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
      'interests': interests,
      'position': position?.name,
      'height': height,
      'handedness': handedness,
      'category': category,
      'nationality': nationality,
      'pronoun': pronoun,
      'gender': gender,
      'age': age,
      'pastClubs': pastClubs,
      'division': division,
      'league': league,
      'certificationLevel': certificationLevel,
      'yearsExperience': yearsExperience,
      'coachedCategories': coachedCategories,
      'location': location,
      'city': city,
      'province': province,
      'country': country,
      'trainingDays': trainingDays,
      'federatedCategories': federatedCategories,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    Uint8List? localPhotoBytes,
    String? bio,
    int? followersCount,
    int? followingCount,
    List<String>? followers,
    List<String>? following,
    List<String>? interests,
    String? pronoun,
    String? gender,
    int? age,
    String? pastClubs,
    String? division,
    String? league,
    PlayerPosition? position,
    double? height,
    String? category,
    String? location,
    String? city,
    String? province,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoBytes: localPhotoBytes ?? this.localPhotoBytes,
      bio: bio ?? this.bio,
      role: role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      interests: interests ?? this.interests,
      position: position ?? this.position,
      height: height ?? this.height,
      handedness: handedness,
      category: category ?? this.category,
      nationality: nationality,
      pronoun: pronoun ?? this.pronoun,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      pastClubs: pastClubs ?? this.pastClubs,
      division: division ?? this.division,
      league: league ?? this.league,
      certificationLevel: certificationLevel,
      yearsExperience: yearsExperience,
      coachedCategories: coachedCategories,
      location: location ?? this.location,
      city: city ?? this.city,
      province: province ?? this.province,
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

enum PostType { text, photo, video, event, result }

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
  final PostType type;
  final String? mediaUrl;
  final Uint8List? localMediaBytes;
  final String? mediaType; // 'photo' | 'video'
  final String? caption;
  final List<PostTag> tags;
  final int likeCount;
  final int commentCount;
  final List<String> likedBy;
  final String? location;
  final DateTime createdAt;

  // Event-specific
  final String? eventTitle;
  final String? eventDate;
  final String? eventPlace;

  // Result-specific
  final String? teamA;
  final String? teamB;
  final String? scoreA;
  final String? scoreB;

  const PostModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    this.authorRole,
    this.type = PostType.photo,
    this.mediaUrl,
    this.localMediaBytes,
    this.mediaType,
    this.caption,
    this.tags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedBy = const [],
    this.location,
    required this.createdAt,
    this.eventTitle,
    this.eventDate,
    this.eventPlace,
    this.teamA,
    this.teamB,
    this.scoreA,
    this.scoreB,
  });

  static PostType _typeFromString(String s) {
    switch (s) {
      case 'text': return PostType.text;
      case 'video': return PostType.video;
      case 'event': return PostType.event;
      case 'result': return PostType.result;
      default: return PostType.photo;
    }
  }

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
      type: _typeFromString(data['type'] ?? 'photo'),
      mediaUrl: data['mediaUrl'],
      mediaType: data['mediaType'],
      caption: data['caption'],
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((t) => _tagFromString(t as String))
          .toList(),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventTitle: data['eventTitle'],
      eventDate: data['eventDate'],
      eventPlace: data['eventPlace'],
      teamA: data['teamA'],
      teamB: data['teamB'],
      scoreA: data['scoreA'],
      scoreB: data['scoreB'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'authorRole': authorRole,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'tags': tags.map((t) => t.label).toList(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likedBy': likedBy,
      'location': location,
      'eventTitle': eventTitle,
      'eventDate': eventDate,
      'eventPlace': eventPlace,
      'teamA': teamA,
      'teamB': teamB,
      'scoreA': scoreA,
      'scoreB': scoreB,
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
      type: type,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      caption: caption,
      tags: tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      likedBy: likedBy ?? this.likedBy,
      location: location,
      createdAt: createdAt,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventPlace: eventPlace,
      teamA: teamA,
      teamB: teamB,
      scoreA: scoreA,
      scoreB: scoreB,
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
