import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  Uint8List? _mediaBytes;
  bool _isVideo = false;
  String _videoExtension = '';
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

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: AppColors.primary),
                title: const Text('Subir Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam, color: AppColors.primary),
                title: const Text('Subir Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _mediaBytes = bytes;
        _isVideo = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov'],
      withData: true, 
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El video es demasiado grande (máx 50MB).')));
        }
        return;
      }
      setState(() {
        _mediaBytes = file.bytes;
        _isVideo = true;
        _videoExtension = file.extension ?? 'mp4';
      });
    }
  }

  Future<void> _publish() async {
    if (_mediaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una foto o video.')));
      return;
    }
    setState(() => _loading = true);
    try {
      if (_isVideo) {
        // Delegar subida de video al controller pasándole la data
        await ref.read(interactionControllerProvider).uploadPostVideoData(
          _mediaBytes!,
          _videoExtension,
          _captionCtrl.text,
          _selectedHashtags.toList()
        );
      } else {
        // Subida de imagen nativa
        final user = ref.read(currentUserProvider).valueOrNull;
        if (user == null) return;
        final postRepo = ref.read(postRepositoryProvider);
        final mediaUrl = await postRepo.uploadPostMedia(user.uid, _mediaBytes!, 'photo');
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
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Publicación creada exitosamente!'), backgroundColor: Colors.green));
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
    final user = ref.watch(currentUserProvider).valueOrNull;
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6), // Beige claro
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: primaryColor),
                    onPressed: () => context.go('/home'),
                  ),
                  Text(
                    'Crear Publicación',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'KINETIC',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Profile Info header if user is loaded
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: (user.photoUrl?.isNotEmpty ?? false) 
                        ? NetworkImage(user.photoUrl!) 
                        : null,
                      backgroundColor: Colors.grey.shade300,
                      child: (user.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, color: Colors.grey) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          user.roleLabel.toUpperCase(),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upload Area
                    GestureDetector(
                      onTap: _showMediaPicker,
                      child: CustomPaint(
                        painter: _DottedBorderPainter(color: primaryColor.withOpacity(0.5)),
                        child: Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: _mediaBytes != null
                              ? (_isVideo) 
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.videocam, size: 48, color: AppColors.primary),
                                      const SizedBox(height: 8),
                                      const Text('Video listo para publicar', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 16),
                                      TextButton.icon(
                                        onPressed: _showMediaPicker, 
                                        icon: const Icon(Icons.refresh), 
                                        label: const Text('Cambiar video')
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.memory(
                                      _mediaBytes!, 
                                      fit: BoxFit.cover, 
                                      width: double.infinity, 
                                      height: double.infinity,
                                    ),
                                  )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Toca para subir',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '(PNG, JPG o MP4)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Caption Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _captionCtrl,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: '¿Qué quieres compartir hoy?',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sugerencias
                    Text(
                      'SUGERENCIAS',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _hashtags.map((tag) {
                        final isSelected = _selectedHashtags.contains(tag);
                        return FilterChip(
                          label: Text(
                            tag, 
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: Colors.white,
                          selectedColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: primaryColor.withOpacity(isSelected ? 1.0 : 0.3),
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
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
                    
                    const SizedBox(height: 40),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _loading ? null : _publish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24, 
                              width: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              'PUBLICAR AHORA', 
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  _DottedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );
    path.addRRect(rrect);

    // Create a dashed path
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double distance = 0.0;
    
    final metrics = path.computeMetrics();
    final dashedPath = Path();
    for (final metric in metrics) {
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashWidth), 
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
