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
    (PostTag.soloContenido, '📱 Solo Contenido', AppColors.tagSoloContenido),
    (PostTag.buscoClub, '🏐 Busco Club', AppColors.tagBuscoClub),
    (PostTag.buscoJugador, '👤 Busco Jugador', AppColors.tagBuscoJugador),
    (PostTag.buscoEntrenador, '📋 Busco Entrenador', AppColors.tagBuscoEntrenador),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _loading ? null : _publish,
              child: _loading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                  : const Text('Publicar',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
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
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _imageBytes != null ? AppColors.primary : AppColors.divider,
                    width: _imageBytes != null ? 2 : 1,
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.primary, size: 32),
                          ),
                          const SizedBox(height: 16),
                          const Text('Toca para seleccionar foto',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                          const SizedBox(height: 6),
                          const Text('JPG, PNG, MP4',
                              style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Caption
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              maxLength: 300,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Escribí un caption... (posición, categoría, logros...)',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Icon(Icons.edit_note, color: AppColors.textHint),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tags
            Text('Estado / Tag', style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Clasificá tu publicación para que el Mercado la indexe correctamente',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
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
                        _selectedTags.add(tagOption.$1);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? tagOption.$3.withOpacity(0.2) : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? tagOption.$3 : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(tagOption.$2,
                      style: TextStyle(
                        color: isSelected ? tagOption.$3 : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 14,
                      ),
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
