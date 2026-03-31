import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // Solo para registro
  
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  
  // Actúa como interruptor de la UI dentro de la misma tarjeta
  bool _isRegistering = false; 

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor, llena todos los campos necesarios');
      return;
    }
    
    setState(() { _loading = true; _error = null; });
    try {
      if (_isRegistering) {
        final name = _nameCtrl.text.trim();
        if (name.isEmpty) throw Exception('Escribe tu nombre para el registro'); // Basic validation
        // Flujo de Registro 
        await ref.read(authRepositoryProvider).registerWithEmail(email, pass, name);
      } else {
        // Flujo de Inicio de Sesión
        await ref.read(authRepositoryProvider).signInWithEmail(email, pass);
      }
      
      // La regla estricta del app_router ahora nos interceptará automáticamente 
      // y si el session-state cambió al entrar, nos mandará a /home.
      if (mounted) context.go('/home'); 
    } catch (e) {
      setState(() { 
        _error = _isRegistering ? 'Error al crear la cuenta, intenta con otro email' : 'Email o contraseña incorrectos'; 
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE5E7EB); // Gris clarito para el fondo detrás de la carta
    const cardColor = Colors.white;
    const inputColor = Color(0xFFF3F4F6); // Gris súper sutil para inputs
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- TARJETA CENTRAL KINETIC (Paper on Glass) ---
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LOGO Y TÍTULO
                    const Center(
                      child: Text(
                        'VolleyNet',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _isRegistering ? 'Crea tu Cuenta' : 'Bienvenido',
                        style: const TextStyle(
                          color: Color(0xFF1A2F4B), // Custom dark marine
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // FORMULARIO DINÁMICO
                    AnimatedSize(
                      duration: 300.ms,
                      curve: Curves.easeInOutBack,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isRegistering) ...[
                            _buildLabelRow('NOMBRE COMPLETO'),
                            _buildTextField(
                              controller: _nameCtrl,
                              icon: Icons.person_outline,
                              hint: 'Ej: Mateo Seohane',
                              fillColor: inputColor,
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          _buildLabelRow('EMAIL O USUARIO'),
                          _buildTextField(
                            controller: _emailCtrl,
                            icon: Icons.email_outlined,
                            hint: 'tu@ejemplo.com',
                            fillColor: inputColor,
                            inputType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          
                          _buildLabelRow(
                            'CONTRASEÑA', 
                            trailing: !_isRegistering ? GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviando enlace de recuperación...')));
                              },
                              child: const Text(
                                'OLVIDÉ MI CONTRASEÑA',
                                style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ) : null
                          ),
                          _buildTextField(
                            controller: _passCtrl,
                            icon: Icons.lock_outline,
                            hint: '••••••••',
                            fillColor: inputColor,
                            isPassword: true,
                          ),
                        ],
                      ),
                    ),
                    
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                        .animate().shakeX(),
                    ],

                    const SizedBox(height: 16),
                    if (!_isRegistering)
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: false,
                              onChanged: (v) {},
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              activeColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Recuérdame', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),

                    const SizedBox(height: 32),
                    
                    // BOTONES DE ACCIÓN
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isRegistering ? 'Crear Cuenta' : 'Iniciar Sesión', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _toggleMode,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(_isRegistering ? 'Ya tengo cuenta, iniciar sesión' : 'Registrarse', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),

                    const SizedBox(height: 32),
                    
                    // SOCIAL LOGIN DIVIDER
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O CONTINUAR CON', style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SOCIAL BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Google Auth SDK...')));
                            },
                            icon: const Icon(Icons.g_mobiledata, color: Colors.black87), // Mock Icon
                            label: const Text('GOOGLE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Apple Auth SDK...')));
                            },
                            icon: const Icon(Icons.apple, color: Colors.black87), // Mock Icon
                            label: const Text('APPLE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPERS PARA UI ---
  Widget _buildLabelRow(String label, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required Color fillColor,
    bool isPassword = false,
    TextInputType? inputType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscure : false,
      keyboardType: inputType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Colors.black38, size: 20),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.black38, size: 20),
          onPressed: () => setState(() => _obscure = !_obscure),
        ) : null,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
