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
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final isOwnProfile = targetUid == currentUser?.uid;
    final profileAsync = uid != null
        ? ref.watch(userProfileProvider(targetUid))
        : AsyncData<UserModel?>(currentUser);
    final postsAsync = ref.watch(userPostsProvider(targetUid));

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('Usuario no encontrado')));
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            actions: isOwnProfile
                ? [
                    IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) context.go('/auth/login');
                      },
                    ),
                  ]
                : null,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + stats row
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider, width: 1),
                              color: AppColors.surfaceVariant,
                            ),
                            child: ClipOval(
                              child: user.photoUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.person_outline, size: 48, color: AppColors.textHint),
                            ),
                          ),
                          const SizedBox(width: 28),
                          // Stats
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatItem(label: 'Posts', value: postsAsync.valueOrNull?.length.toString() ?? '0'),
                                _StatItem(label: 'Seguidores', value: user.followersCount.toString()),
                                _StatItem(label: 'Siguiendo', value: user.followingCount.toString()),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Name + Role Badge
                      Text(user.displayName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 18)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.sports_volleyball, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(user.roleLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      
                      // Location Pin
                      if (user.city != null || user.location != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textHint),
                            const SizedBox(width: 4),
                            Text(user.city ?? user.location ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ],
                      
                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(user.bio!, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ],
                      const SizedBox(height: 16),
                      
                      // Role-specific info chips
                      _RoleInfoChips(user: user),
                      const SizedBox(height: 24),
                      
                      // Edit profile Button
                      if (isOwnProfile)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Editar perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final currentUid = currentUser!.uid;
                                  final isFollowing = user.followers.contains(currentUid);
                                  if (isFollowing) {
                                    await ref.read(userRepositoryProvider).unfollowUser(currentUid, user.uid);
                                  } else {
                                    await ref.read(userRepositoryProvider).followUser(currentUid, user.uid);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: user.followers.contains(currentUser?.uid)
                                      ? AppColors.surfaceVariant : AppColors.primary,
                                ),
                                child: Text(user.followers.contains(currentUser?.uid) ? 'Siguiendo' : 'Seguir'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.send_outlined, size: 16),
                                label: const Text('Mensaje'),
                                onPressed: () async {
                                  if (currentUser == null) return;
                                  final convId = await ref.read(messageRepositoryProvider)
                                      .getOrCreateConversation(currentUser, user);
                                  if (context.mounted) {
                                    context.go('/messages/$convId', extra: user);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      
                      // Tabs
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.grid_on, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text('PUBLICACIONES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Posts grid
              postsAsync.when(
                loading: () => const SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)))),
                error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('Aún no tienes publicaciones',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                        ),
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final post = posts[i];
                        return GestureDetector(
                          onTap: () {},
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: post.mediaUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: AppColors.surfaceVariant),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.sports_volleyball, color: AppColors.textHint),
                                ),
                              ),
                              if (post.tags.isNotEmpty && post.tags.first != PostTag.soloContenido)
                                Positioned(
                                  top: 6, right: 6,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: post.tags.first == PostTag.buscoClub
                                          ? AppColors.tagBuscoClub : post.tags.first == PostTag.buscoJugador
                                          ? AppColors.tagBuscoJugador : AppColors.tagBuscoEntrenador,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: posts.length,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFF63A8FF), fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _RoleInfoChips extends StatelessWidget {
  final UserModel user;
  const _RoleInfoChips({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[];
    switch (user.role) {
      case UserRole.player:
        if (user.position != null) items.add(('P', user.position!));
        if (user.height != null) items.add(('A', '${user.height!.toInt()} cm'));
        if (user.handedness != null) items.add(('H', user.handedness!));
        if (user.category != null) items.add(('C', user.category!));
        break;
      case UserRole.coach:
        if (user.certificationLevel != null) items.add(('C', user.certificationLevel!));
        if (user.yearsExperience != null) items.add(('E', '${user.yearsExperience} años'));
        break;
      case UserRole.club:
        if (user.city != null) items.add(('C', user.city!));
        if (user.trainingDays != null) items.add(('D', user.trainingDays!));
        break;
    }
    
    // In image: Líbero, 170, Derecha, Mayores. Just text, maybe small colored bullets.
    if (items.isEmpty) return const SizedBox();
    
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: items.map((item) {
        // Asignar un color sutil al iconito inicial según tipo
        Color dotColor;
        if (item.$1 == 'A') dotColor = Colors.yellow.shade700;
        else if (item.$1 == 'H') dotColor = Colors.amber;
        else dotColor = AppColors.primary;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141624),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(item.$2, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
