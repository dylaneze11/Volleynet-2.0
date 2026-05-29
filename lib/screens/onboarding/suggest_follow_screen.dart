import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class SuggestFollowScreen extends ConsumerStatefulWidget {
  const SuggestFollowScreen({super.key});

  @override
  ConsumerState<SuggestFollowScreen> createState() => _SuggestFollowScreenState();
}

class _SuggestFollowScreenState extends ConsumerState<SuggestFollowScreen> {
  List<UserModel> _suggestions = [];
  final Set<String> _followingUids = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    final userRepo = ref.read(userRepositoryProvider);
    final suggestions = await userRepo.getSuggestedUsers(
      currentUser.uid,
      currentUser.following,
      location: currentUser.city,
      province: currentUser.province,
      role: currentUser.role,
    );

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFollow(UserModel target) async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    if (_followingUids.contains(target.uid)) {
      setState(() => _followingUids.remove(target.uid));
      await ref.read(userRepositoryProvider).unfollowUser(currentUser.uid, target.uid);
    } else {
      setState(() => _followingUids.add(target.uid));
      await ref.read(userRepositoryProvider).followUser(currentUser.uid, target.uid);
    }
  }

  Future<void> _done() async {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;

    if (_followingUids.isEmpty) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('¿Seguro que querés saltar?'),
          content: const Text('Tu feed se va a ver vacío hasta que sigas a alguien. Siempre podés seguir gente después desde el menú Explorar.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Elegir personas')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Ir al feed'),
            ),
          ],
        ),
      );
      if (go != true) return;
    }

    if (mounted) context.go('/home');
  }

  void _skip() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_outline, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '¿A quién querés seguir?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu feed se arma con lo que publiquen las personas y clubes que sigas.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Suggestions List
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _suggestions.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No encontramos sugerencias por ahora.\nPodés explorar gente después.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceVariant),
                          itemBuilder: (context, index) {
                            final user = _suggestions[index];
                            final isFollowing = _followingUids.contains(user.uid);
                            return _SuggestionCard(
                              user: user,
                              isFollowing: isFollowing,
                              onToggle: () => _toggleFollow(user),
                            );
                          },
                        ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _done,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _followingUids.isEmpty ? 'Saltar por ahora' : 'Listo (${_followingUids.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  if (_followingUids.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _skip,
                      child: const Text(
                        'Saltar por ahora',
                        style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  if (_followingUids.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Podés seguir personas después desde el menú Explorar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondary.withOpacity(0.7), fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final UserModel user;
  final bool isFollowing;
  final VoidCallback onToggle;

  const _SuggestionCard({
    required this.user,
    required this.isFollowing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: ClipOval(
              child: user.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user.photoUrl!,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                    )
                  : const Icon(Icons.person, color: AppColors.secondary, size: 28),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  user.roleLabel,
                  style: TextStyle(color: AppColors.secondary.withOpacity(0.8), fontSize: 12),
                ),
                if (user.city != null || user.province != null)
                  Text(
                    [user.city, user.province].where((e) => e != null && e.isNotEmpty).join(', '),
                    style: TextStyle(color: AppColors.secondary.withOpacity(0.6), fontSize: 11),
                  ),
              ],
            ),
          ),

          // Follow button
          SizedBox(
            height: 34,
            child: isFollowing
                ? OutlinedButton(
                    onPressed: onToggle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.success, width: 1.5),
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 16),
                        SizedBox(width: 4),
                        Text('Siguiendo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: onToggle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Seguir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
          ),
        ],
      ),
    );
  }
}
