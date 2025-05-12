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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Messages', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: messages.length,
        separatorBuilder: (context, i) => Divider(indent: 70, endIndent: 16, height: 1, color: AppTheme.primaryColor.withOpacity(0.08)),
        itemBuilder: (context, i) {
          final msg = messages[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage(msg['avatar'] as String),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                ),
                if (msg['online'] == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              msg['name'] as String,
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            subtitle: Text(
              msg['message'] as String,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  msg['time'] as String,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
                ),
                if ((msg['unread'] as int) > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['unread'].toString(),
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
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