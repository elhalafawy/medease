import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'about_app_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  // String email;
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.kPaddingXLarge,
            vertical: AppTheme.kPaddingXLarge,
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundImage: AssetImage('assets/images/profile_picture.png'),
                ),
              ),
              const SizedBox(height: AppTheme.kPaddingLarge),
              Text(
                'Ahmed Elhalafawy',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.kPaddingSmall),
              Text(
                'ahmed.elhlafawy@email.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppTheme.kPaddingXLarge),
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
                      context: context,
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildProfileOption(
                      context: context,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        context.push('/change-password');
                      },
                    ),
                    _buildProfileOption(
                      context: context,
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () {
                        context.push('/notifications');
                      },
                    ),
                    _buildProfileOption(
                      context: context,
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      context: context,
                      icon: Icons.info_outline,
                      title: 'About App',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      context: context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () {
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.kPaddingMedium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}
