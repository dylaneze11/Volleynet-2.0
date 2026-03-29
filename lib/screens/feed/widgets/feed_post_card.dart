import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';

class FeedPostCard extends StatelessWidget {
  final PostModel post;

  const FeedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('es', timeago.EsMessages());
    final timeString = timeago.format(post.createdAt, locale: 'es');

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Avatar & Name)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: post.authorPhotoUrl != null 
                      ? CachedNetworkImageProvider(post.authorPhotoUrl!) 
                      : null,
                  child: post.authorPhotoUrl == null 
                      ? const Icon(Icons.person, color: AppColors.secondary) 
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (post.location != null)
                        Text(
                          post.location!,
                          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Image
          CachedNetworkImage(
            imageUrl: post.mediaUrl,
            fit: BoxFit.cover,
            height: 350,
            width: double.infinity,
            placeholder: (context, url) => Container(
              height: 350,
              color: AppColors.surfaceVariant,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 350,
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.error),
            ),
          ),
          
          // Actions (Like, Comment, Share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Likes Info & Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likeCount} me gusta',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '${post.authorName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (post.commentCount > 0) ...[
                  Text(
                    'Ver los ${post.commentCount} comentarios',
                    style: const TextStyle(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  timeString,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
