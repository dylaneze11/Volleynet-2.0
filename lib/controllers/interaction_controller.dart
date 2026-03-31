import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/providers.dart';

final interactionControllerProvider = Provider((ref) => InteractionController(ref));

class InteractionController {
  final Ref ref;
  InteractionController(this.ref);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// LÓGICA: Botón de Publicar Video (Recibe la data desde file_picker en UI)
  Future<void> uploadPostVideoData(Uint8List fileBytes, String extension, String caption, List<String> hashtags) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.uid.isEmpty) {
      throw Exception('Debes estar autenticado para publicar.');
    }

    try {
      // Subir a Firebase Storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_video.$extension';
      final Reference storageRef = _storage.ref().child('posts_videos/${user.uid}/$fileName');
      
      final contentParams = SettableMetadata(contentType: 'video/$extension');
      final UploadTask uploadTask = storageRef.putData(fileBytes, contentParams);

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Formatear caption con hashtags
      final fullCaption = '$caption ${hashtags.join(" ")}'.trim();

      // 4. Crear documento del Post
      await _firestore.collection('posts').add({
        'authorUid': user.uid,
        'authorName': user.displayName ?? 'Sin Nombre',
        'authorPhotoUrl': user.photoUrl,
        'authorRole': user.roleLabel,
        'mediaUrl': downloadUrl,
        'mediaType': 'video', // Marcador para la UI
        'caption': fullCaption,
        'tags': ['PostTag.soloContenido'], 
        'createdAt': FieldValue.serverTimestamp(),
        // Metadatos Deportivos (Scouting):
        'scoutData': {
          'playerPosition': user.positionLabel,
          'height': user.height ?? 0,
        },
        'likesCount': 0,
        'commentsCount': 0,
      });

    } catch (e) {
      throw Exception('Error al publicar video: $e');
    }
  }

  /// LÓGICA: Botón de Contactar Club/Coach (Negociar)
  Future<void> sendConnectionRequest(String targetUserId) async {
    final currentUser = ref.read(currentUserProvider).value;
    
    if (currentUser == null) {
      throw Exception('Debes estar autenticado para conectar.');
    }

    // Validación de Metadatos de scouting básicos para conectar
    if (currentUser.displayName == null || currentUser.displayName!.isEmpty ||
        currentUser.position == null || 
        (currentUser.height == null || currentUser.height == 0)) {
      throw Exception('Debes completar tu perfil (Nombre, Posición y Altura) antes de contactar o negociar.');
    }

    try {
      await _firestore.collection('connection_requests').add({
        'fromUserId': currentUser.uid,
        'toUserId': targetUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'applicantData': {
          'name': currentUser.displayName,
          'position': currentUser.positionLabel,
          'height': currentUser.height,
        }
      });
    } catch (e) {
      throw Exception('Error al enviar la solicitud: $e');
    }
  }
}
