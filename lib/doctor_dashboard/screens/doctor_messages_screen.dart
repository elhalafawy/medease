import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorMessagesScreen extends StatelessWidget {
  const DoctorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        'name': 'mohamed',
        'message': 'Hi Dr.Ahmed,',
        'time': '19:37',
        'avatar': 'assets/images/profile_picture.png',
        'online': true,
        'unread': 1,
      },
      {
        'name': 'Ahmed',
        'message': 'I am cardio patient.',
        'time': '19:37',
        'avatar': 'assets/images/profile_picture.png',
        'online': true,
        'unread': 2,
      },
      {
        'name': 'menna',
        'message': 'Thanks dude.',
        'time': '19:37',
        'avatar': 'assets/images/profile_picture.png',
        'online': true,
        'unread': 0,
      },
      {
        'name': 'manar',
        'message': 'I need your help imidiately.',
        'time': '19:37',
        'avatar': 'assets/images/profile_picture.png',
        'online': true,
        'unread': 0,
      },
      {
        'name': 'rana',
        'message': 'Thanks you Dr.Ahmed',
        'time': '19:37',
        'avatar': 'assets/images/profile_picture.png',
        'online': true,
        'unread': 0,
      },
    ];
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Messages', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: messages.length,
        separatorBuilder: (context, i) => Divider(indent: 70, endIndent: 16, height: 1, color: theme.colorScheme.primary.withOpacity(0.08)),
        itemBuilder: (context, i) {
          final msg = messages[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(msg['avatar'] as String),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                ),
                if (msg['online'] == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              msg['name'] as String,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            subtitle: Text(
              msg['message'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg['time'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if ((msg['unread'] as int) > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['unread'].toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
} 