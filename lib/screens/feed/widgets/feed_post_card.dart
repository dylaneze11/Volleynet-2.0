import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';

class FeedPostCard extends ConsumerStatefulWidget {
  final PostModel post;

  const FeedPostCard({super.key, required this.post});

  @override
  ConsumerState<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends ConsumerState<FeedPostCard> {
  late bool _isLiked;
  late int _likeCount;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _initializeLocalState();
  }

  @override
  void didUpdateWidget(FeedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      _initializeLocalState();
    }
  }

  void _initializeLocalState() {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    _isLiked = currentUser != null && widget.post.isLikedBy(currentUser.uid);
    _likeCount = widget.post.likeCount;
  }

  void _handleLike() {
    final currentUser = ref.read(currentUserProvider).valueOrNull;
    if (currentUser == null) return;
    
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    
    ref.read(postRepositoryProvider).toggleLike(widget.post.id, currentUser.uid);
  }

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('es', timeago.EsMessages());
    final timeString = timeago.format(widget.post.createdAt, locale: 'es');
    
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

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
                  backgroundImage: widget.post.authorPhotoUrl != null 
                      ? CachedNetworkImageProvider(widget.post.authorPhotoUrl!) 
                      : null,
                  child: widget.post.authorPhotoUrl == null 
                      ? const Icon(Icons.person, color: AppColors.secondary) 
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (widget.post.location != null)
                        Text(
                          widget.post.location!,
                          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.share, color: Colors.blue),
                                title: const Text('Compartir en...'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace preparado para compartir exteriormente')));
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.visibility_off),
                                title: const Text('Ocultar publicación'),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esta publicación ha sido ocultada')));
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.report, color: Colors.red),
                                title: const Text('Reportar', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gracias, tu reporte será revisado.')));
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Image
          CachedNetworkImage(
            imageUrl: widget.post.mediaUrl,
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
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ).animate(target: _isLiked ? 1 : 0)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 200.ms, curve: Curves.easeOutBack)
                   .then()
                   .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1), duration: 200.ms, curve: Curves.easeOutBack),
                  onPressed: _handleLike,
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () {
                    if (currentUser != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => _CommentsSheet(post: widget.post, currentUser: currentUser),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return Container(
                          height: 320,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                child: Text('Enviar a...', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: 8,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Colors.grey.shade200,
                                            child: Icon(Icons.person, color: Colors.grey.shade400, size: 35),
                                          ),
                                          const SizedBox(height: 8),
                                          Text('Perfil ${index+1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enviado a Perfil ${index+1} 🚀'), duration: const Duration(seconds: 2)));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary, 
                                                foregroundColor: Colors.white, 
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                              ),
                                              child: const Text('Enviar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                            )
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                )
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.link),
                                  label: const Text('Copiar enlace de video', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: BorderSide(color: Colors.grey.shade300, width: 2)
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enlace copiado al portapapeles ✅')));
                                  },
                                ),
                              )
                            ],
                          )
                        );
                      }
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: _isSaved ? AppColors.primary : Colors.black87,
                    size: 28,
                  ).animate(target: _isSaved ? 1 : 0)
                   .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 150.ms, curve: Curves.easeOut)
                   .then()
                   .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 150.ms, curve: Curves.easeOut),
                  onPressed: () {
                    setState(() {
                      _isSaved = !_isSaved;
                    });
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_isSaved ? 'Guardado en tus colecciones' : 'Eliminado de tus guardados'),
                      duration: const Duration(seconds: 2),
                    ));
                  },
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
                  '$_likeCount me gusta',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                if (widget.post.caption != null && widget.post.caption!.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '${widget.post.authorName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: widget.post.caption!),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (widget.post.commentCount > 0) ...[
                  GestureDetector(
                    onTap: () {
                      if (currentUser != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _CommentsSheet(post: widget.post, currentUser: currentUser),
                        );
                      }
                    },
                    child: Text(
                      'Ver los ${widget.post.commentCount} comentarios',
                      style: const TextStyle(color: AppColors.secondary),
                    ),
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

class _CommentsSheet extends ConsumerStatefulWidget {
  final PostModel post;
  final UserModel currentUser;

  const _CommentsSheet({required this.post, required this.currentUser});

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final comment = CommentModel(
        id: '',
        authorUid: widget.currentUser.uid,
        authorName: widget.currentUser.displayName,
        authorPhotoUrl: widget.currentUser.photoUrl,
        text: text,
        createdAt: DateTime.now(),
      );
      await ref.read(postRepositoryProvider).addComment(widget.post.id, comment);
      _commentCtrl.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al comentar: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.post.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Spacer para centrar título
                const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Comments List
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(child: Text('No hay comentarios aún. ¡Sé el primero!', style: TextStyle(color: Colors.grey)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         CircleAvatar(
                          radius: 16,
                          backgroundImage: (comment.authorPhotoUrl?.isNotEmpty ?? false)
                            ? CachedNetworkImageProvider(comment.authorPhotoUrl!)
                            : null,
                          backgroundColor: Colors.grey.shade300,
                          child: (comment.authorPhotoUrl?.isEmpty ?? true) ? const Icon(Icons.person, color: Colors.grey, size: 16) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeago.format(comment.createdAt, locale: 'es'),
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.text, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
          
          // Input Area
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                ],
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 18,
                    backgroundImage: (widget.currentUser.photoUrl?.isNotEmpty ?? false)
                        ? CachedNetworkImageProvider(widget.currentUser.photoUrl!) 
                        : null,
                    backgroundColor: Colors.grey.shade300,
                    child: (widget.currentUser.photoUrl?.isEmpty ?? true)
                        ? const Icon(Icons.person, size: 18, color: Colors.grey) 
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'Añade un comentario...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
