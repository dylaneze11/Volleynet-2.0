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
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: Text(isOwnProfile ? 'Mi Perfil' : 'Perfil'),
            actions: isOwnProfile
                ? [
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/auth/login');
                      },
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 4),
                      color: AppColors.surfaceVariant,
                    ),
                    child: ClipOval(
                      child: user.localPhotoBytes != null
                          ? Image.memory(user.localPhotoBytes!, fit: BoxFit.cover, width: 120, height: 120)
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
                ),
                const SizedBox(height: 16),
                
                // Name & Info
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.pronoun != null && user.pronoun!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.pronoun!,
                    style: const TextStyle(color: AppColors.secondary, fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                
                // Position & Category Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user.positionLabel.isNotEmpty ? user.positionLabel : "Jugador"} · ${user.category ?? "Libre"}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatColumn(
                      label: 'Publicaciones', 
                      count: postsAsync.value?.length.toString() ?? '-',
                    ),
                    const SizedBox(width: 24),
                    _StatColumn(
                      label: 'Seguidores', 
                      count: user.followersCount.toString(),
                    ),
                    const SizedBox(width: 24),
                    _StatColumn(
                      label: 'Seguidos', 
                      count: user.followingCount.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Bio
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  Text(
                    user.bio!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Status Chip (Busco Club)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Busco Club',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Primary Action Button
                if (isOwnProfile)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/edit-profile'),
                      child: const Text('Editar perfil'),
                    ),
                  )
                else
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
                
                const SizedBox(height: 24),
                
                // Additional Actions
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.bar_chart,
                        title: 'Mis estadísticas',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.emoji_events,
                        title: 'Mis logros',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Ficha Deportiva (Bento Info)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Ficha Deportiva',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _InfoItem(label: 'Edad', value: user.age != null ? '${user.age} años' : '-')),
                          Expanded(child: _InfoItem(label: 'Altura', value: user.height != null ? '${user.height} cm' : '-')),
                          Expanded(child: _InfoItem(label: 'Género', value: user.gender ?? '-')),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Expanded(child: _InfoItem(label: 'División', value: user.division ?? '-')),
                          Expanded(child: _InfoItem(label: 'Liga', value: user.league ?? '-')),
                        ],
                      ),
                      if (user.pastClubs != null && user.pastClubs!.isNotEmpty) ...[
                        const Divider(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Historial de Clubes', style: TextStyle(color: AppColors.secondary, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(
                                user.pastClubs!,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Highlights / Posts
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mejores Momentos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                
                postsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.secondary),
                            const SizedBox(height: 16),
                            const Text(
                              'Sin publicaciones',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: posts.length,
                      itemBuilder: (ctx, i) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: posts[i].mediaUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
                            errorWidget: (_, __, ___) => Container(
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.error),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceVariant, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 14),
        ),
      ],
    );
  }
}
