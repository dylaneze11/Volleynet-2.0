import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/profile'),
        ),
        title: const Text('Mensajes'),
      ),
      body: conversations.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (convs) {
          if (convs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 80, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('Sin mensajes aún', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Contactá a jugadores o clubes desde el Mercado',
                      style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (ctx, i) {
              final conv = convs[i];
              final otherId = conv.participantIds.firstWhere(
                  (id) => id != currentUser?.uid, orElse: () => conv.participantIds.first);
              final otherName = conv.participantNames[otherId] ?? 'Usuario';
              final otherPhoto = conv.participantPhotos[otherId];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: otherPhoto != null ? CachedNetworkImageProvider(otherPhoto) : null,
                  child: otherPhoto == null
                      ? Text(otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                      : null,
                ),
                title: Text(otherName,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                subtitle: Text(conv.lastMessage ?? '...',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                trailing: conv.lastMessageAt != null
                    ? Text(timeago.format(conv.lastMessageAt!, locale: 'es'),
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11))
                    : null,
                onTap: () {
                  // Navigate to chat - in full impl fetch other user profile
                  context.go('/messages/${conv.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
