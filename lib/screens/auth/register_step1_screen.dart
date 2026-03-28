import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../core/theme/app_theme.dart';

class RegisterStep1Screen extends StatelessWidget {
  const RegisterStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/auth/login'),
        ),
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Quién sos en el vóley?',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Elegí tu rol para personalizar tu perfil',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 36),
              _RoleCard(
                emoji: '🏐',
                title: 'Jugador/a',
                subtitle: 'Armador, Libero, Punta, Central, Opuesto',
                role: UserRole.player,
                gradient: [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.15),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '📋',
                title: 'Entrenador/a',
                subtitle: 'Director técnico · Asistente · Preparador físico',
                role: UserRole.coach,
                gradient: [const Color(0xFF065F46), const Color(0xFF10B981)],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.15),
              const SizedBox(height: 16),
              _RoleCard(
                emoji: '🏟️',
                title: 'Club / Institución',
                subtitle: 'Clubes · Asociaciones · Ligas',
                role: UserRole.club,
                gradient: [const Color(0xFF7C2D12), AppColors.primary],
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.15),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final UserRole role;
  final List<Color> gradient;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.role,
    required this.gradient,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/auth/register/details', extra: widget.role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient.map((c) => _hovered ? c : c.withOpacity(0.15)).toList(),
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? widget.gradient.last : widget.gradient.last.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.gradient.last.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]
                : [],
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _hovered ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(widget.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _hovered ? Colors.white70 : AppColors.textSecondary,
                        )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 18,
                  color: _hovered ? Colors.white : AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
