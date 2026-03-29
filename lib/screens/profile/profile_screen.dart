import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final targetUid = uid ?? currentUser?.uid;

    if (targetUid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isOwnProfile = targetUid == currentUser?.uid;
    final profileAsync = uid != null
        ? ref.watch(userProfileProvider(targetUid))
        : AsyncData<UserModel?>(currentUser);
    final postsAsync = ref.watch(userPostsProvider(targetUid));

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('Usuario no encontrado')));
        
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.sports_volleyball, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'VolleyNet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black87),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.refresh(currentUserProvider);
              if (targetUid != null) {
                ref.refresh(userProfileProvider(targetUid));
                ref.refresh(userPostsProvider(targetUid));
              }
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Avatar with Edit Badge
                  Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: user.localPhotoBytes != null
                              ? Image.memory(user.localPhotoBytes!, fit: BoxFit.cover, width: 140, height: 140)
                              : (user.photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: AppColors.surfaceVariant, child: const Icon(Icons.person, size: 60, color: AppColors.secondary))),
                        ),
                      ),
                      if (isOwnProfile)
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Role
                  Text(
                    user.positionLabel.isNotEmpty ? user.positionLabel.toUpperCase() : "JUGADOR LIBRE",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  
                  // Name (Split by space to have multiple lines if possible, or just standard bold italic)
                  Text(
                    user.displayName.toUpperCase().replaceAll(' ', '\n'), 
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: const Color(0xFF111827),
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Username and Club
                  Text(
                    '@${user.email.split('@')[0]} • ${user.pastClubs?.split('\n').first ?? "Sin Club"}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatColumn(count: postsAsync.value?.length.toString() ?? '0', label: 'PUBLICACIONES'),
                      _StatColumn(count: '1.2k', label: 'SEGUIDORES'), // Mock as per design image
                      _StatColumn(count: '382', label: 'SEGUIDOS'), // Mock as per design image
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  if (isOwnProfile) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/edit-profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Compartir', style: TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: const Text('Seguir'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Mensaje'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  // Ajustes de Cuenta
                  if (isOwnProfile) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'AJUSTES DE CUENTA',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            title: 'Información Personal',
                            subtitle: 'Email, teléfono, dirección',
                            onTap: () {},
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Icons.lock_outline,
                            title: 'Privacidad y Seguridad',
                            subtitle: 'Contraseña, visibilidad del perfil',
                            onTap: () {},
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Icons.credit_card_outlined,
                            title: 'Métodos de Pago',
                            subtitle: 'Suscripciones, tarjetas guardadas',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Soporte
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SOPORTE',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.help_outline,
                            title: 'Centro de Ayuda',
                            subtitle: '',
                            onTap: () {},
                          ),
                          _divider(),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            title: 'Términos y Condiciones',
                            subtitle: '',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Outlined Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.withOpacity(0.2), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).signOut();
                          if (context.mounted) context.go('/auth/login');
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _divider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade200, indent: 24, endIndent: 24);
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
