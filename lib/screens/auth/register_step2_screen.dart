import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';

class RegisterStep2Screen extends ConsumerStatefulWidget {
  final UserRole role;
  const RegisterStep2Screen({super.key, required this.role});

  @override
  ConsumerState<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends ConsumerState<RegisterStep2Screen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  // Player
  PlayerPosition? _position;
  String? _handedness;
  String? _category;
  double? _height;
  // Coach
  String? _certLevel;
  int? _yearsExp;
  // Club
  final _locationCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const _positions = [
    PlayerPosition.setter, PlayerPosition.libero, PlayerPosition.outside,
    PlayerPosition.middle, PlayerPosition.opposite,
  ];
  static const _categories = ['Mini-vóley', 'Infantil', 'Cadete', 'Junior', 'Mayor'];
  static const _certLevels = ['Nivel I', 'Nivel II', 'Nivel III', 'Internacional'];
  static const _handednessList = ['Diestro/a', 'Zurdo/a'];

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Completá todos los campos obligatorios');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);
      final cred = await authRepo.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      final user = UserModel(
        uid: cred.user!.uid,
        displayName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
        role: widget.role,
        position: _position,
        height: _height,
        handedness: _handedness,
        category: _category,
        certificationLevel: _certLevel,
        yearsExperience: _yearsExp,
        location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : null,
        city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
        createdAt: DateTime.now(),
      );
      await userRepo.updateProfile(cred.user!.uid, user.toFirestore());
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Error al crear la cuenta: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _roleIcon {
    switch (widget.role) {
      case UserRole.player: return '🏐';
      case UserRole.coach: return '📋';
      case UserRole.club: return '🏟️';
    }
  }

  String get _roleLabel {
    switch (widget.role) {
      case UserRole.player: return 'Jugador/a';
      case UserRole.coach: return 'Entrenador/a';
      case UserRole.club: return 'Club / Institución';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/auth/register'),
        ),
        title: const Text('Tu perfil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text('$_roleIcon  $_roleLabel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600,
                    )),
              ),
              const SizedBox(height: 24),
              // Common fields
              _SectionLabel('Datos básicos'),
              const SizedBox(height: 12),
              _Field(controller: _nameCtrl, hint: 'Nombre completo / Nombre del club',
                  icon: Icons.person_outline),
              const SizedBox(height: 12),
              _Field(controller: _emailCtrl, hint: 'Email', icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textHint),
                  hintText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textHint),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Field(controller: _bioCtrl, hint: 'Bio (opcional)', icon: Icons.info_outline, maxLines: 2),
              const SizedBox(height: 24),

              // Role-specific fields
              if (widget.role == UserRole.player) ...[
                _SectionLabel('Datos de jugador'),
                const SizedBox(height: 12),
                _DropdownField<PlayerPosition>(
                  hint: 'Posición',
                  value: _position,
                  items: _positions,
                  labelFor: (p) => p.name == 'setter' ? 'Armador/a' : p.name == 'libero' ? 'Líbero' :
                      p.name == 'outside' ? 'Punta' : p.name == 'middle' ? 'Central' : 'Opuesto/a',
                  onChanged: (v) => setState(() => _position = v),
                  icon: Icons.sports_volleyball_outlined,
                ),
                const SizedBox(height: 12),
                _DropdownField<String>(
                  hint: 'Categoría',
                  value: _category,
                  items: _categories,
                  labelFor: (c) => c,
                  onChanged: (v) => setState(() => _category = v),
                  icon: Icons.military_tech_outlined,
                ),
                const SizedBox(height: 12),
                _DropdownField<String>(
                  hint: 'Brazo hábil',
                  value: _handedness,
                  items: _handednessList,
                  labelFor: (h) => h,
                  onChanged: (v) => setState(() => _handedness = v),
                  icon: Icons.back_hand_outlined,
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (v) => _height = double.tryParse(v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.height, color: AppColors.textHint),
                    hintText: 'Altura (cm)',
                  ),
                ),
              ],

              if (widget.role == UserRole.coach) ...[
                _SectionLabel('Datos de entrenador'),
                const SizedBox(height: 12),
                _DropdownField<String>(
                  hint: 'Nivel de certificación',
                  value: _certLevel,
                  items: _certLevels,
                  labelFor: (c) => c,
                  onChanged: (v) => setState(() => _certLevel = v),
                  icon: Icons.workspace_premium_outlined,
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (v) => _yearsExp = int.tryParse(v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.timer_outlined, color: AppColors.textHint),
                    hintText: 'Años de experiencia',
                  ),
                ),
              ],

              if (widget.role == UserRole.club) ...[
                _SectionLabel('Datos del club'),
                const SizedBox(height: 12),
                _Field(controller: _cityCtrl, hint: 'Ciudad', icon: Icons.location_city_outlined),
                const SizedBox(height: 12),
                _Field(controller: _locationCtrl, hint: 'Ubicación / Dirección', icon: Icons.place_outlined),
              ],

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(
      color: AppColors.primary, fontWeight: FontWeight.w600,
    ));
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _Field({required this.controller, required this.hint, required this.icon,
      this.keyboardType, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textHint),
        hintText: hint,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelFor;
  final void Function(T?) onChanged;
  final IconData icon;

  const _DropdownField({required this.hint, required this.value, required this.items,
      required this.labelFor, required this.onChanged, required this.icon});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.surfaceVariant,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.textHint),
        hintText: hint,
      ),
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(labelFor(item), style: Theme.of(context).textTheme.bodyLarge),
      )).toList(),
    );
  }
}
