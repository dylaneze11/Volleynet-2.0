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
            title: Text(user.displayName),
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
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.surfaceVariant,
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!) : null,
                              child: user.photoUrl == null
                                  ? Text(
                                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                    )
                                  : null,
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
                      const SizedBox(height: 16),
                      // Name + role badge
                      Row(
                        children: [
                          Text(user.displayName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(width: 10),
                          _RoleBadge(role: user.role),
                        ],
                      ),
                      // Bio
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(user.bio!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 16),
                      // Role-specific info card
                      _RoleInfoCard(user: user),
                      const SizedBox(height: 16),
                      // Buttons
                      if (!isOwnProfile) ...[
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
                      if (isOwnProfile)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('Editar perfil'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Grid divider
              const SliverToBoxAdapter(child: Divider(height: 1)),
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
                          child: Column(
                            children: [
                              Icon(Icons.grid_off, color: AppColors.textHint, size: 48),
                              SizedBox(height: 12),
                              Text('Aún no hay publicaciones',
                                  style: TextStyle(color: AppColors.textHint)),
                            ],
                          ),
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
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    String emoji;
    Color color;
    String label;
    switch (role) {
      case UserRole.player: emoji = '🏐'; color = AppColors.tagBuscoClub; label = 'Jugador/a'; break;
      case UserRole.coach: emoji = '📋'; color = AppColors.tagBuscoEntrenador; label = 'Entrenador/a'; break;
      case UserRole.club: emoji = '🏟️'; color = AppColors.primary; label = 'Club'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text('$emoji  $label', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _RoleInfoCard extends StatelessWidget {
  final UserModel user;
  const _RoleInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[];
    switch (user.role) {
      case UserRole.player:
        if (user.position != null) items.add((Icons.sports_volleyball_outlined, 'Posición', user.positionLabel));
        if (user.height != null) items.add((Icons.height, 'Altura', '${user.height!.toInt()} cm'));
        if (user.handedness != null) items.add((Icons.back_hand_outlined, 'Habilidad', user.handedness!));
        if (user.category != null) items.add((Icons.military_tech_outlined, 'Categoría', user.category!));
        break;
      case UserRole.coach:
        if (user.certificationLevel != null) items.add((Icons.workspace_premium_outlined, 'Certificación', user.certificationLevel!));
        if (user.yearsExperience != null) items.add((Icons.timer_outlined, 'Experiencia', '${user.yearsExperience} años'));
        break;
      case UserRole.club:
        if (user.city != null) items.add((Icons.location_city_outlined, 'Ciudad', user.city!));
        if (user.location != null) items.add((Icons.place_outlined, 'Dirección', user.location!));
        if (user.trainingDays != null) items.add((Icons.calendar_today_outlined, 'Entrenamiento', user.trainingDays!));
        break;
    }
    if (items.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.$1, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('${item.$2}: ', style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
            Text(item.$3, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        )).toList(),
      ),
    );
  }
}
