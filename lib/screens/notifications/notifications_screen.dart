import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        children: [
          _NotifItem(
            avatar: null,
            emoji: '🏐',
            title: 'GarciaVóley',
            subtitle: 'le dio Me Gusta a tu publicación',
            time: 'hace 5 min',
          ),
          _NotifItem(
            avatar: null,
            emoji: '👤',
            title: 'ClubAtlético',
            subtitle: 'empezó a seguirte',
            time: 'hace 1 h',
          ),
          _NotifItem(
            avatar: null,
            emoji: '💬',
            title: 'MartinezCoach',
            subtitle: 'comentó: "¡Excelente nivel de juego!"',
            time: 'hace 2 h',
          ),
          _NotifItem(
            avatar: null,
            emoji: '📋',
            title: 'Club Ferro',
            subtitle: 'te envió un mensaje directo',
            time: 'ayer',
          ),
        ],
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
