import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedPostsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Outfit', // Assuming outfit is applied globally by theme
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Volley', style: TextStyle(color: AppColors.primary)),
              TextSpan(text: 'Net', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () => context.go('/messages'),
          ),
        ],
      ),
      body: feed.when(
        loading: () => _buildShimmerFeed(),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyFeed(context);
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(feedPostsProvider),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, i) => PostCard(post: posts[i], currentUid: currentUser?.uid ?? ''),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerFeed() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => const _ShimmerPost(),
    );
  }

  Widget _buildEmptyFeed(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF231A17), // Dark slightly warm/reddish tint matching image
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports_volleyball, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('¡Bienvenido a VolleyNet!', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                )),
            const SizedBox(height: 12),
            Text('Aún no hay publicaciones. ¡Sé el primero en compartir!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ), 
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class PostCard extends ConsumerStatefulWidget {
  final PostModel post;
  final String currentUid;

  const PostCard({super.key, required this.post, required this.currentUid});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _showComments = false;
  final _commentCtrl = TextEditingController();

  Future<void> _toggleLike() async {
    await ref.read(postRepositoryProvider).toggleLike(widget.post.id, widget.currentUid);
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final comment = CommentModel(
      id: '',
      authorUid: user.uid,
      authorName: user.displayName,
      authorPhotoUrl: user.photoUrl,
      text: text,
      createdAt: DateTime.now(),
    );
    await ref.read(postRepositoryProvider).addComment(widget.post.id, comment);
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.isLikedBy(widget.currentUid);
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/profile/${post.authorUid}'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: post.authorPhotoUrl != null
                        ? CachedNetworkImageProvider(post.authorPhotoUrl!) : null,
                    child: post.authorPhotoUrl == null
                        ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14)),
                      if (post.authorRole != null)
                        Text(post.authorRole!, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                    ],
                  ),
                ),
                // Tags
                if (post.tags.isNotEmpty) _buildTagChip(post.tags.first),
                const SizedBox(width: 8),
                const Icon(Icons.more_horiz, color: AppColors.textHint),
              ],
            ),
          ),

          // Media
          AspectRatio(
            aspectRatio: 1,
            child: CachedNetworkImage(
              imageUrl: post.mediaUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, _) => Container(color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))),
              errorWidget: (ctx, _, __) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.sports_volleyball, color: AppColors.textHint, size: 48),
              ),
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      key: ValueKey(isLiked),
                      Icons.sports_volleyball,
                      color: isLiked ? AppColors.primary : AppColors.textHint,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${post.likeCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(width: 18),
                GestureDetector(
                  onTap: () => setState(() => _showComments = !_showComments),
                  child: const Icon(Icons.chat_bubble_outline, color: AppColors.textHint, size: 24),
                ),
                const SizedBox(width: 6),
                Text('${post.commentCount}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const Spacer(),
                const Icon(Icons.bookmark_border_outlined, color: AppColors.textHint, size: 24),
              ],
            ),
          ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: '${post.authorName}  ',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14)),
                  TextSpan(text: post.caption, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                ]),
              ),
            ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(timeago.format(post.createdAt, locale: 'es'),
                style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
          ),

          // Comments section
          if (_showComments) _CommentsSection(postId: post.id, commentCtrl: _commentCtrl, onSubmit: _submitComment),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildTagChip(PostTag tag) {
    Color color;
    switch (tag) {
      case PostTag.buscoClub: color = AppColors.tagBuscoClub; break;
      case PostTag.buscoJugador: color = AppColors.tagBuscoJugador; break;
      case PostTag.buscoEntrenador: color = AppColors.tagBuscoEntrenador; break;
      default: color = AppColors.tagSoloContenido;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(tag.displayLabel, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _CommentsSection extends ConsumerWidget {
  final String postId;
  final TextEditingController commentCtrl;
  final VoidCallback onSubmit;

  const _CommentsSection({required this.postId, required this.commentCtrl, required this.onSubmit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentsProvider(postId));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          comments.when(
            loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
            error: (e, _) => const SizedBox(),
            data: (comments) => Column(
              children: comments.take(5).map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${c.authorName}  ', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 13)),
                    Expanded(child: Text(c.text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                  ],
                ),
              )).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Añadí un comentario...',
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSubmit,
                child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerPost extends StatelessWidget {
  const _ShimmerPost();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 120, height: 12, color: AppColors.surfaceVariant),
                  const SizedBox(height: 6),
                  Container(width: 80, height: 10, color: AppColors.surfaceVariant),
                ]),
              ],
            ),
          ),
          Container(height: 300, color: AppColors.surfaceVariant),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
