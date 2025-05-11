import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'about_app_screen.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  // String email;
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage('assets/images/profile_picture.png'),
              ),
              const SizedBox(height: 16),
              Text(
                'Ahmed Elhalafawy',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'ahmed.elhlafawy@email.com',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
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
  icon: Icons.lock_outline,
  title: 'Change Password',
  onTap: () {
    context.push('/change-password');

  },
),

                    _buildProfileOption(
  icon: Icons.notifications_none,
  title: 'Notifications',
  onTap: () {
    context.push('/notifications');
  },
),

                    _buildProfileOption(
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
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF022E5B)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF022E5B),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
