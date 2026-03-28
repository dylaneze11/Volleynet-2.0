import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../feed/feed_screen.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final Set<String> _selectedTags = {};

  static const _filterTags = [
    ('BuscoClub', '🏐 Busco Club', AppColors.tagBuscoClub),
    ('BuscoJugador', '👤 Busco Jugador', AppColors.tagBuscoJugador),
    ('BuscoEntrenador', '📋 Busco DT', AppColors.tagBuscoEntrenador),
  ];

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(marketPostsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mercado', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Tablón de fichajes', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: '⚡ Todos',
                    isSelected: _selectedTags.isEmpty,
                    color: AppColors.primary,
                    onTap: () {
                      setState(() {
                        _selectedTags.clear();
                        ref.read(marketFilterProvider.notifier).state = [];
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._filterTags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: tag.$2,
                      isSelected: _selectedTags.contains(tag.$1),
                      color: tag.$3,
                      onTap: () {
                        setState(() {
                          if (_selectedTags.contains(tag.$1)) {
                            _selectedTags.remove(tag.$1);
                          } else {
                            _selectedTags.add(tag.$1);
                          }
                          ref.read(marketFilterProvider.notifier).state = _selectedTags.toList();
                        });
                      },
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmpty(context);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(marketPostsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (ctx, i) => _MarketCard(
                post: posts[i],
                currentUid: currentUser?.uid ?? '',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('No hay publicaciones', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Aún no hay jugadores o clubes buscando equipo',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: 1.5),
        ),
        child: Text(label,
          style: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MarketCard extends ConsumerWidget {
  final PostModel post;
  final String currentUid;

  const _MarketCard({required this.post, required this.currentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color tagColor;
    final tag = post.tags.isNotEmpty ? post.tags.first : PostTag.soloContenido;
    switch (tag) {
      case PostTag.buscoClub: tagColor = AppColors.tagBuscoClub; break;
      case PostTag.buscoJugador: tagColor = AppColors.tagBuscoJugador; break;
      case PostTag.buscoEntrenador: tagColor = AppColors.tagBuscoEntrenador; break;
      default: tagColor = AppColors.tagSoloContenido;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tagColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Tag header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: tagColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(tag.displayLabel,
                    style: TextStyle(color: tagColor, fontWeight: FontWeight.w700, fontSize: 12)),
                const Spacer(),
                Text(timeago.format(post.createdAt, locale: 'es'),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media preview
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: post.mediaUrl,
                    width: 85,
                    height: 85,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 85, height: 85,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.sports_volleyball, color: AppColors.textHint, size: 32),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 85, height: 85,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.sports_volleyball, color: AppColors.textHint, size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 15)),
                      if (post.authorRole != null)
                        Text(post.authorRole!, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                      const SizedBox(height: 6),
                      if (post.caption != null && post.caption!.isNotEmpty)
                        Text(post.caption!,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.sports_volleyball, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text('${post.likeCount}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.chat_bubble_outline, color: AppColors.textHint, size: 14),
                          const SizedBox(width: 4),
                          Text('${post.commentCount}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contact button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.send_outlined, size: 16),
                label: const Text('Contactar'),
                onPressed: () {
                  // Navigate to chat with this user
                  // Full implementation requires fetching user profile first
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: tagColor,
                  side: BorderSide(color: tagColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
