import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/screens/settings_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_notifications_screen.dart';
import '../../features/auth/screens/login_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  static final ValueNotifier<bool> deletionPending = ValueNotifier(false);

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _EditDoctorProfileSheet(),
    );
  }

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
                  const Text('My Profile', style: AppTheme.titleLarge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showEditProfile(context),
                behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const CircleAvatar(
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
                        const Text('Ahmedmo@gmail.com', style: AppTheme.bodyMedium),
                      ],
                    ),
                  ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                    ),
                ],
                ),
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
                        MaterialPageRoute(
                          builder: (_) => const DoctorNotificationsScreen(appointmentsCount: 2),
                        ),
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
                    onTap: () async {
                      if (!deletionPending.value) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to request account deletion?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const _RequestSuccessDialog(),
                      );
                          deletionPending.value = true;
                        }
                      }
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
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
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
    if (title == 'Request Account Deletion') {
      return ValueListenableBuilder<bool>(
        valueListenable: DoctorProfileScreen.deletionPending,
        builder: (context, pending, _) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title, style: AppTheme.bodyLarge),
          trailing: pending
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                )
              : const Icon(Icons.chevron_right, color: AppTheme.greyColor),
          onTap: pending ? null : onTap,
        ),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: AppTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.greyColor),
      onTap: onTap,
    );
  }
}

class _EditDoctorProfileSheet extends StatefulWidget {
  const _EditDoctorProfileSheet();

  @override
  State<_EditDoctorProfileSheet> createState() => _EditDoctorProfileSheetState();
}

class _EditDoctorProfileSheetState extends State<_EditDoctorProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: 'Dr.Ahmed');
  final TextEditingController _expController = TextEditingController(text: '15yr');
  final TextEditingController _specController = TextEditingController(text: 'Neurologist');
  final TextEditingController _emailController = TextEditingController(text: 'Ahmed mo@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '+201027206804');
  final TextEditingController _hospitalController = TextEditingController(text: 'Al Shifa Hospital');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppTheme.textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text('Edit Profile', style: AppTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('Full Name', _nameController),
              const SizedBox(height: 16),
              _buildField('Years Of Experience', _expController),
              const SizedBox(height: 16),
              _buildField('specialization', _specController),
              const SizedBox(height: 16),
              _buildField('Hospital', _hospitalController),
              const SizedBox(height: 16),
              _buildField('Email', _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Phone', _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}

class _RequestSuccessDialog extends StatelessWidget {
  const _RequestSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/password_success.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'Request sent successfully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00264D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your account deletion request has been received and is pending review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00264D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 