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
  
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Por favor, introduce tus datos.');
      return;
    }
    
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, pass);
      // El ruteador redirige automáticamente al detectar la sesión activa.
    } catch (e) {
      setState(() => _error = 'Email o contraseña incorrectos');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE5E7EB);
    const cardColor = Colors.white;
    const inputColor = Color(0xFFF3F4F6); // Fondo sutil para inputs estilo Instagram
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- TARJETA PRINCIPAL (Instagram Style) ---
              Container(
                width: 400,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
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
                          fontSize: 42,
                          fontFamily: 'Inter', // Si no hay una fuente logo, Inter/Lexend
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // FORMULARIO DE LOGIN
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'Teléfono, usuario o correo electrónico',
                      fillColor: inputColor,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildTextField(
                      controller: _passCtrl,
                      hint: 'Contraseña',
                      fillColor: inputColor,
                      isPassword: true,
                    ),
                    
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.normal), textAlign: TextAlign.center)
                        .animate().shakeX(),
                    ],

                    const SizedBox(height: 24),
                    
                    // BOTÓN INICIAR SESIÓN
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Radio suave estilo IG
                        ),
                        child: _loading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Iniciar sesión', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // DIVIDER "O"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SOCIAL LOGIN (Mocked)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Google Auth SDK...')));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.g_mobiledata, color: AppColors.primary, size: 28),
                            SizedBox(width: 4),
                            Text('Iniciar sesión con Google', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviando enlace de recuperación...')));
                        },
                        child: const Text('¿Has olvidado la contraseña?', style: TextStyle(color: Color(0xFF1E40AF), fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms, curve: Curves.easeOut).slideY(begin: 0.05, end: 0),
              
              const SizedBox(height: 20),

              // --- TARJETA DE "REGÍSTRATE" ---
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
                    const Text('¿No tienes una cuenta? ', style: TextStyle(color: Colors.black87, fontSize: 14)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.go('/auth/register'),
                      child: const Text('Regístrate', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.05, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color fillColor,
    bool isPassword = false,
    TextInputType? inputType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(6), // Radio pequeño estilo IG
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
