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
  final Set<String> _selectedHashtags = {};
  bool _loading = false;

  static const _hashtags = [
    '#LigaRegional',
    '#Remate',
    '#Entrenamiento',
    '#VoleyFemenino',
    '#VoleyMasculino'
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
        const SnackBar(content: Text('Por favor, selecciona una foto o video.')));
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
        caption: '${_captionCtrl.text.trim()} ${_selectedHashtags.join(" ")}'.trim(),
        tags: [PostTag.soloContenido],
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
      backgroundColor: AppColors.primaryContainer.withOpacity(0.1), // Fondo naranja claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Crear Publicación'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Área punteada para subir archivo
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                    // Idealmente un borde punteado, pero usamos Border normal en default
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.8),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Toca para subir',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'PNG, JPG o MP4 (Max. 10MB)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.secondary,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Input de texto grande
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _captionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '¿Qué quieres compartir hoy?',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.all(24),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Hashtags Chips
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _hashtags.map((tag) {
                final isSelected = _selectedHashtags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedHashtags.add(tag);
                      } else {
                        _selectedHashtags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 48),
            
            // Botón primario Publicar
            ElevatedButton(
              onPressed: _loading ? null : _publish,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Publicar Ahora', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
