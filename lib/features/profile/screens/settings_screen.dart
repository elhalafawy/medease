import 'package:flutter/material.dart';
import '../../../main.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode>? themeModeNotifier;
  const SettingsScreen({super.key, this.themeModeNotifier});

  @override
  Widget build(BuildContext context) {
    final notifier = themeModeNotifier ?? themeModeNotifierGlobal;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const Text('PROFILE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          SwitchListTile(
            value: notifier.value == ThemeMode.dark,
            onChanged: (val) {
              notifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
            title: const Text('Dark Mode'),
            activeColor: const Color(0xFF022E5B),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: const Text('Push Notification'),
            activeColor: const Color(0xFF022E5B),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: const Text('Location'),
            activeColor: Colors.purple,
          ),
          ListTile(
            title: const Text('Language'),
            trailing: const Text('English'),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          const Text('OTHER', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            title: const Text('Terms and Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

final ValueNotifier<ThemeMode> themeModeNotifierGlobal = themeModeNotifier;
