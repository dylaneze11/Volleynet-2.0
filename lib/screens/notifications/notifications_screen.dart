import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.notifications_none_outlined, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant, // Dark bluish grey matches image
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_outlined, size: 48, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Text('Sin notificaciones', 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  )),
              const SizedBox(height: 12),
              Text('Cuando alguien interactúe con tu contenido, lo verás aquí.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ), 
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final String? avatar;
  final String emoji;
  final String title;
  final String subtitle;
  final String time;

  const _NotifItem({this.avatar, required this.emoji, required this.title,
      required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.surfaceVariant,
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
      title: RichText(
        text: TextSpan(children: [
          TextSpan(text: '$title  ', style: const TextStyle(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14)),
          TextSpan(text: subtitle, style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400)),
        ]),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(time, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ),
      tileColor: AppColors.surface.withOpacity(0.3),
      trailing: const SizedBox(width: 8, height: 8,
        child: DecoratedBox(decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
    );
  }
}
