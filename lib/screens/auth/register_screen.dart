import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  bool _loading = false;
  String? _error;

  // --- Step 0: Basic Info ---
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  // --- Step 1: Role ---
  UserRole? _selectedRole;

  // --- Step 2: Extras (Opcionales) ---
  final _bioCtrl = TextEditingController();
  
  // Player
  PlayerPosition? _position;
  String? _category;
  String? _handedness;
  double? _height;
  
  // Coach
  String? _certLevel;
  int? _yearsExp;
  
  // Club
  final _cityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  static const _positions = [
    PlayerPosition.setter, PlayerPosition.libero, PlayerPosition.outside,
    PlayerPosition.middle, PlayerPosition.opposite,
  ];
  static const _categories = ['Mini-vóley', 'Infantil', 'Cadete', 'Junior', 'Mayor'];
  static const _certLevels = ['Nivel I', 'Nivel II', 'Nivel III', 'Internacional'];
  static const _handednessList = ['Diestro/a', 'Zurdo/a'];

  void _nextStep() {
    setState(() => _error = null);

    if (_currentStep == 0) {
      if (_emailCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
        setState(() => _error = 'Por favor, llena los campos básicos');
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_selectedRole == null) {
        setState(() => _error = 'Debes seleccionar un rol para continuar');
        return;
      }
      setState(() => _currentStep = 2);
    }
  }

  void _prevStep() {
    setState(() {
      _error = null;
      if (_currentStep > 0) _currentStep--;
    });
  }

  Future<void> _submitRegistration() async {
    setState(() { _loading = true; _error = null; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final userRepo = ref.read(userRepositoryProvider);
      
      // 1. Firebase Auth Registration
      final cred = await authRepo.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      
      // 2. Build User Model (All extras are optional)
      final user = UserModel(
        uid: cred.user!.uid,
        displayName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isNotEmpty ? _bioCtrl.text.trim() : null,
        role: _selectedRole ?? UserRole.player,
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
      
      // 3. Save User Data
      await authRepo.createUserProfile(user);
      
      // (Wait for authStateProvider to kick in and redirect via app_router.dart automatically)
      
    } catch (e) {
      setState(() => _error = 'Error al registrarte: Verifica los datos e intenta con otro email.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE5E7EB);
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- TARJETA PRINCIPAL REGISTRO ---
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO E INDICADOR
                    const Center(
                      child: Text(
                        'VolleyNet',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 42,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Regístrate para ver contenido de tus amigos y unirte a la red.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('PASO ${_currentStep + 1} DE 3', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // CONTENIDO DINÁMICO ANIMADO
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Container(
                        key: ValueKey<int>(_currentStep),
                        child: _buildStepContent(),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center)
                        .animate().shakeX(),
                    ],

                    const SizedBox(height: 24),

                    // BOTONERA
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : (_currentStep < 2 ? _nextStep : _submitRegistration),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_currentStep < 2 ? 'Siguiente' : 'Registrarte', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      ),
                    ),
                    
                    if (_currentStep > 0) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: TextButton(
                          onPressed: _loading ? null : _prevStep,
                          child: const Text('Volver atrás', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ]
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05),
              
              const SizedBox(height: 20),

              // --- TARJETA INFERIOR LOGIN ---
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Tienes una cuenta? ', style: TextStyle(color: Colors.black87, fontSize: 14)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.go('/auth/login'),
                      child: const Text('Entrar', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: Step Views

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep0BasicInfo();
      case 1: return _buildStep1RoleSelect();
      case 2: return _buildStep2Extras();
      default: return const SizedBox();
    }
  }

  Widget _buildStep0BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(controller: _emailCtrl, hint: 'Correo electrónico', inputType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildTextField(controller: _nameCtrl, hint: 'Nombre completo'),
        const SizedBox(height: 12),
        _buildTextField(controller: _passCtrl, hint: 'Contraseña', isPassword: true),
      ],
    );
  }

  Widget _buildStep1RoleSelect() {
    return Column(
      children: [
        _buildRoleTile(UserRole.player, 'Jugador/a', 'Me quiero unir a la red como deportista'),
        const SizedBox(height: 12),
        _buildRoleTile(UserRole.coach, 'Entrenador/a', 'Quiero gestionar mi vida como técnico'),
        const SizedBox(height: 12),
        _buildRoleTile(UserRole.club, 'Club/Institución', 'Represento de manera oficial a una entidad'),
      ],
    );
  }

  Widget _buildRoleTile(UserRole role, String title, String target) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
                  Text(target, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Extras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Estos datos son opcionales, puedes rellenarlos luego en tu perfil.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 20),
        _buildTextField(controller: _bioCtrl, hint: 'Añadir biografía (Opcional)'),
        const SizedBox(height: 12),

        if (_selectedRole == UserRole.player) ...[
          _DropdownField<PlayerPosition>(
            hint: 'Posición de juego',
            value: _position,
            items: _positions,
            labelFor: (p) => p.name == 'setter' ? 'Armador/a' : p.name == 'libero' ? 'Líbero' :
                p.name == 'outside' ? 'Punta' : p.name == 'middle' ? 'Central' : 'Opuesto/a',
            onChanged: (v) => setState(() => _position = v),
          ),
          const SizedBox(height: 12),
          _DropdownField<String>(
            hint: 'Categoría', value: _category, items: _categories, labelFor: (c) => c,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 12),
          _DropdownField<String>(
            hint: 'Brazo hábil', value: _handedness, items: _handednessList, labelFor: (h) => h,
            onChanged: (v) => setState(() => _handedness = v),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: TextField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              onChanged: (v) => _height = double.tryParse(v),
              decoration: const InputDecoration(hintText: 'Altura (cm)', hintStyle: TextStyle(color: Colors.black45, fontSize: 12), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: InputBorder.none),
            ),
          ),
        ],

        if (_selectedRole == UserRole.coach) ...[
          _DropdownField<String>(
            hint: 'Nivel de certificación', value: _certLevel, items: _certLevels, labelFor: (c) => c,
            onChanged: (v) => setState(() => _certLevel = v),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade300, width: 1)),
            child: TextField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              onChanged: (v) => _yearsExp = int.tryParse(v),
              decoration: const InputDecoration(hintText: 'Años de experiencia', hintStyle: TextStyle(color: Colors.black45, fontSize: 12), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14), border: InputBorder.none),
            ),
          ),
        ],

        if (_selectedRole == UserRole.club) ...[
          _buildTextField(controller: _cityCtrl, hint: 'Ciudad (Opcional)'),
          const SizedBox(height: 12),
          _buildTextField(controller: _locationCtrl, hint: 'Dirección (Opcional)'),
        ],
      ],
    );
  }

  // MARK: UI Helpers

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType? inputType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscure : false,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 12),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black45, size: 18),
            onPressed: () => setState(() => _obscure = !_obscure),
          ) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
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

  const _DropdownField({required this.hint, required this.value, required this.items, required this.labelFor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          onChanged: onChanged,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Colors.black45, fontSize: 12)),
          style: const TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'Inter'),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(labelFor(item)),
          )).toList(),
        ),
      ),
    );
  }
}
