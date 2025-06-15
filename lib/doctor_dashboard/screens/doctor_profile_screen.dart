import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/screens/settings_screen.dart';
import 'doctor_messages_screen.dart';
import 'doctor_notifications_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  static final ValueNotifier<bool> deletionPending = ValueNotifier(false);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, dynamic>? doctor;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctor();
  }

  Future<void> fetchDoctor() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final response = await Supabase.instance.client
        .from('doctors')
        .select('*')
        .eq('user_id', user.id)
        .maybeSingle();
    setState(() {
      doctor = response;
      loading = false;
    });
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditDoctorProfileSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, size: 22, color: theme.colorScheme.primary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('My Profile', style: theme.textTheme.titleLarge),
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
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: const AssetImage('assets/images/doctor_photo.png') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor?['name'] ?? '', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          const SizedBox(height: 2),
                          Text(doctor?['email'] ?? '', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Icon(Icons.edit, size: 20, color: theme.colorScheme.primary),
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
                  Text('Profile', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
                  Text('Support', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
                      if (!DoctorProfileScreen.deletionPending.value) {
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
                                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
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
                          DoctorProfileScreen.deletionPending.value = true;
                        }
                      }
                    },
                  ),
                  _ProfileListTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),
            const Spacer(),
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
  final Color? iconColor;

  const _ProfileListTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (title == 'Request Account Deletion') {
      return ValueListenableBuilder<bool>(
        valueListenable: DoctorProfileScreen.deletionPending,
        builder: (context, pending, _) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(title, style: theme.textTheme.bodyLarge),
          trailing: pending
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pending',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                  ),
                )
              : Icon(Icons.arrow_forward_ios, size: 20, color: theme.colorScheme.onSurfaceVariant),
          onTap: onTap,
        ),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Icon(Icons.arrow_forward_ios, size: 20, color: theme.colorScheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}

class _EditDoctorProfileSheet extends StatefulWidget {
  final Map<String, dynamic>? doctor;
  const _EditDoctorProfileSheet({this.doctor});

  @override
  State<_EditDoctorProfileSheet> createState() => _EditDoctorProfileSheetState();
}

class _EditDoctorProfileSheetState extends State<_EditDoctorProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _expController;
  late TextEditingController _specController;
  late TextEditingController _hospitalController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.doctor?['name'] ?? '');
    _expController = TextEditingController(text: widget.doctor?['years_of_experience']?.toString() ?? '');
    _specController = TextEditingController(text: widget.doctor?['specialization'] ?? '');
    _hospitalController = TextEditingController(text: widget.doctor?['hospital'] ?? '');
    _emailController = TextEditingController(text: widget.doctor?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.doctor?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expController.dispose();
    _specController.dispose();
    _hospitalController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                      icon: Icon(Icons.arrow_back_ios_new, size: 22, color: theme.colorScheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Edit Profile', style: theme.textTheme.titleLarge),
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
                          SnackBar(
                            content: const Text('Profile updated successfully!'),
                            backgroundColor: theme.colorScheme.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text('Save', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.background,
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
            Text(
              'Request sent successfully!',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your account deletion request has been received and is pending review.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Text(
                  'Continue',
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 