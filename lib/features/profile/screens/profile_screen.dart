import 'package:flutter/material.dart';
import '../../../core/supabase/auth_service.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'about_app_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  Map<String, dynamic>? _patientProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatientProfile();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when returning to this screen
    if (ModalRoute.of(context)?.isCurrent == true) {
      _loadPatientProfile();
    }
  }

  Future<void> _loadPatientProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }
      
      // Get patient data
      final response = await _supabase
          .from('patients')
          .select()
          .eq('user_id', user.id)
          .single();
          
      if (mounted) {
        setState(() {
          _patientProfile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      final user = _supabase.auth.currentUser;
      if (e is PostgrestException && e.message.contains('No rows found') && user != null) {
        await _createPatientProfile(user.id);
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Create patient profile if it doesn't exist
  Future<void> _createPatientProfile(String userId) async {
    try {
      // Get user data
      final userData = await _supabase
          .from('users')
          .select('full_name, email, phone, gender, date_of_birth')
          .eq('id', userId)
          .single();
      
      // Create patient
      final response = await _supabase
          .from('patients')
          .insert({
            'user_id': userId,
            'full_name': userData['full_name'] ?? 'Patient',
            'email': userData['email'],
            'contact_info': userData['phone'] ?? '',
            'gender': userData['gender'] ?? 'other',
            'date_of_birth': userData['date_of_birth'] ?? '2000-01-01',
          })
          .select()
          .single();
      
      if (mounted) {
        setState(() {
          _patientProfile = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating profile: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.kPaddingXLarge,
            vertical: AppTheme.kPaddingXLarge,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: _patientProfile?['profile_image'] != null
                            ? NetworkImage(_patientProfile!['profile_image'])
                            : const AssetImage('assets/images/profile_picture.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: AppTheme.kPaddingLarge),
                    Text(
                      _patientProfile?['full_name'] ?? 'Patient',
                      style: AppTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppTheme.kPaddingSmall),
                    Text(
                      _supabase.auth.currentUser?.email ?? '',
                      style: AppTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppTheme.kPaddingXLarge),
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
                              ).then((_) => _loadPatientProfile());
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
                            onTap: _handleLogout,
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
      margin: const EdgeInsets.only(bottom: AppTheme.kPaddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.kBorderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTheme.titleMedium,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        onTap: onTap,
      ),
    );
  }
}
