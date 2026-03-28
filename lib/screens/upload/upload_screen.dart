import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  Uint8List? _imageBytes;
  final _captionCtrl = TextEditingController();
  final Set<PostTag> _selectedTags = {PostTag.soloContenido};
  bool _loading = false;

  static const _tagOptions = [
    (PostTag.soloContenido, 'Solo Contenido', 'Highlights o fotos normales', Icons.camera_alt, AppColors.tagSoloContenido),
    (PostTag.buscoClub, 'Busco Club', 'Jugadores/entrenadores\nbuscando club', Icons.sports_volleyball, AppColors.tagBuscoClub),
    (PostTag.buscoJugador, 'Busco Jugador', 'Clubes armando equipo', Icons.person, AppColors.tagBuscoJugador),
    (PostTag.buscoEntrenador, 'Busco Entrenador', 'Clubes buscando DT', Icons.assignment, AppColors.tagBuscoEntrenador),
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _publish() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una imagen o video primero')));
      return;
    }
    setState(() => _loading = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      final postRepo = ref.read(postRepositoryProvider);
      final mediaUrl = await postRepo.uploadPostMedia(user.uid, _imageBytes!, 'photo');
      final post = PostModel(
        id: '',
        authorUid: user.uid,
        authorName: user.displayName,
        authorPhotoUrl: user.photoUrl,
        authorRole: user.roleLabel,
        mediaUrl: mediaUrl,
        mediaType: 'photo',
        caption: _captionCtrl.text.trim().isNotEmpty ? _captionCtrl.text.trim() : null,
        tags: _selectedTags.toList(),
        createdAt: DateTime.now(),
      );
      await postRepo.createPost(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicación creada!')));
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40 - 10) / 2; // paddings and spacing
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva Publicación', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: _loading ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.25),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                  : const Text('Publicar', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF141A29), // Deep dark blue background matching image
                  borderRadius: BorderRadius.circular(16),
                  // Emulating dashed border via a standard slightly visible border
                  border: Border.all(color: AppColors.divider.withOpacity(0.3), width: 1.5),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textHint, size: 52),
                          const SizedBox(height: 12),
                          const Text('Toca para subir foto o video',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Caption
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF10131E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider.withOpacity(0.3), width: 1),
              ),
              child: TextField(
                controller: _captionCtrl,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Escribe una descripción...',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  counterText: "",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Tags
            const Text('ETIQUETA DE ESTADO *', style: TextStyle(
              color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _tagOptions.map((tagOption) {
                final isSelected = _selectedTags.contains(tagOption.$1);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        if (_selectedTags.length > 1) _selectedTags.remove(tagOption.$1);
                      } else {
                        _selectedTags.clear();
                        _selectedTags.add(tagOption.$1);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: cardWidth,
                    height: 80,
                    padding: const EdgeInsets.only(left: 12, top: 12, right: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1A1C28) : const Color(0xFF141624),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? tagOption.$5 : AppColors.divider.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(tagOption.$4, size: 16, color: tagOption.$5), // Actually, wait, does tagOption.$5 exist? It's the 5th element! Yes.
                            const SizedBox(width: 6),
                            Expanded(child: Text(tagOption.$2, style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(tagOption.$3, style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500, height: 1.1),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
