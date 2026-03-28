import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _pronounCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _bioCtrl;

  late TextEditingController _positionCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _divisionCtrl;
  late TextEditingController _leagueCtrl;
  late TextEditingController _pastClubsCtrl;

  String? _selectedGender;
  
  Uint8List? _imageBytes;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Hombre', 'Mujer', 'Personalizado'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _pronounCtrl = TextEditingController(text: user?.pronoun ?? '');
    _ageCtrl = TextEditingController(text: user?.age?.toString() ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');

    _positionCtrl = TextEditingController(text: user?.positionLabel ?? '');
    _categoryCtrl = TextEditingController(text: user?.category ?? '');
    _heightCtrl = TextEditingController(text: user?.height?.toString() ?? '');
    _divisionCtrl = TextEditingController(text: user?.division ?? '');
    _leagueCtrl = TextEditingController(text: user?.league ?? '');
    _pastClubsCtrl = TextEditingController(text: user?.pastClubs ?? '');

    _selectedGender = user?.gender;
    _imageBytes = user?.localPhotoBytes;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pronounCtrl.dispose();
    _ageCtrl.dispose();
    _bioCtrl.dispose();

    _positionCtrl.dispose();
    _categoryCtrl.dispose();
    _heightCtrl.dispose();
    _divisionCtrl.dispose();
    _leagueCtrl.dispose();
    _pastClubsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final oldUser = ref.read(mockUserProvider);
      
      final updatedUser = oldUser.copyWith(
        displayName: _nameCtrl.text.trim(),
        pronoun: _pronounCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? oldUser.age,
        gender: _selectedGender,
        bio: _bioCtrl.text.trim(),
        // To properly map position String to PlayerPosition, we just keep string logic in UI for now and skip position enum remapping, or map it:
        // Or if we want to save position, we might need a converter. For now, since `position` is an enum and `category` is string:
        category: _categoryCtrl.text.trim(),
        height: double.tryParse(_heightCtrl.text.trim()) ?? oldUser.height,
        division: _divisionCtrl.text.trim(),
        league: _leagueCtrl.text.trim(),
        pastClubs: _pastClubsCtrl.text.trim(),
        localPhotoBytes: _imageBytes ?? oldUser.localPhotoBytes,
      );

      ref.read(mockUserProvider.notifier).state = updatedUser;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil guardado correctamente')),
        );
        context.pop(); // Go back to profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Photo section
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 4),
                            color: AppColors.surfaceVariant,
                          ),
                          child: ClipOval(
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover, width: 120, height: 120)
                                : (user.photoUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: user.photoUrl!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      )
                                    : const Icon(Icons.person, size: 60, color: AppColors.secondary)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text(
                      'Cambiar foto de perfil',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // ====== INFORMACIÓN BÁSICA ======
                  _buildSectionTitle('Información Básica'),
                  const SizedBox(height: 16),
                  
                  _buildLabeledField(
                    label: 'Nombre visible',
                    controller: _nameCtrl,
                    validator: (val) => val == null || val.isEmpty ? 'El nombre es requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Pronombres',
                          controller: _pronounCtrl,
                          hintText: 'Ej: Él/Ella/Elle',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Edad',
                          controller: _ageCtrl,
                          hintText: 'Ej: 24',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gender Selection (Chips)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Género',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _genderOptions.map((gender) {
                        final isSelected = _selectedGender == gender;
                        return FilterChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGender = gender;
                              } else {
                                _selectedGender = null;
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLabeledField(
                    label: 'Descripción',
                    controller: _bioCtrl,
                    hintText: 'Cuéntanos un poco sobre ti...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  
                  // ====== DATOS DEPORTIVOS ======
                  _buildSectionTitle('Datos Deportivos'),
                  const SizedBox(height: 16),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Posición',
                          controller: _positionCtrl,
                          hintText: 'Ej: Punta, Libre...',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Categoría',
                          controller: _categoryCtrl,
                          hintText: 'Ej: Mayores',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLabeledField(
                          label: 'Altura (cm)',
                          controller: _heightCtrl,
                          hintText: 'Ej: 185',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLabeledField(
                          label: 'División',
                          controller: _divisionCtrl,
                          hintText: 'Ej: División de Honor',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Liga Actual/Pasada',
                    controller: _leagueCtrl,
                    hintText: 'Ej: Liga Metropolitana',
                  ),
                  const SizedBox(height: 16),

                  _buildLabeledField(
                    label: 'Clubes donde jugaste',
                    controller: _pastClubsCtrl,
                    hintText: 'Ej:\nClub Boca Juniors (2020-2022)\nRiver Plate (2018-2020)',
                    maxLines: 4,
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 18,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            // Removing labelText so it purely uses hintText and no floating labels
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}
