import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import 'doctor_messages_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppTheme.primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('My Profile', style: AppTheme.titleLarge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/doctor_photo.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr.Ahmed', style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        const SizedBox(height: 2),
                        Text('Ahmedmo@gmail.com', style: AppTheme.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTheme.greyColor),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Profile', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
                  const SizedBox(height: 8),
                  _ProfileListTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                  _ProfileListTile(
                    icon: Icons.notifications_none,
                    title: 'Notification',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  _ProfileListTile(
                    icon: Icons.mail_outline,
                    title: 'Messages',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DoctorMessagesScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('Support', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
                  const SizedBox(height: 8),
                  _ProfileListTile(
                    icon: Icons.info_outline,
                    title: 'Help Center',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help Center coming soon!')),
                      );
                    },
                  ),
                  _ProfileListTile(
                    icon: Icons.delete_outline,
                    title: 'Request Account Deletion',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Request Account Deletion coming soon!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text('Sign Out', style: AppTheme.titleLarge.copyWith(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ProfileListTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: AppTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppTheme.greyColor),
      onTap: onTap,
    );
  }
} 