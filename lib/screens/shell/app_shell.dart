import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _routes = ['/home', '/market', '/upload', '/notifications', '/profile'];

  void _onTap(int index) {
    if (index == 2) {
      context.go('/upload');
      return;
    }
    context.go(_routes[index]);
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/market')) return 1;
    if (location.startsWith('/upload')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile') || location.startsWith('/messages')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _indexFromLocation(location);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _NavItem(icon: Icons.home_filled, label: 'INICIO',
                    isActive: idx == 0, onTap: () => _onTap(0)),
                _NavItem(icon: Icons.shopping_bag_outlined, label: 'MERCADO',
                    isActive: idx == 1, onTap: () => _onTap(1)),
                // Central publish button
                GestureDetector(
                  onTap: () => _onTap(2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CREAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _NavItem(icon: Icons.notifications_none_rounded, label: 'ALERTAS',
                    isActive: idx == 3, onTap: () => _onTap(3)),
                _NavItem(icon: Icons.person_outline_rounded, label: 'PERFIL',
                    isActive: idx == 4, onTap: () => _onTap(4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.secondary.withOpacity(0.5),
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? AppColors.primary : AppColors.secondary.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
