import 'package:flutter/material.dart';
import '../../../main.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ValueNotifier<ThemeMode>? themeModeNotifier;
  const SettingsScreen({super.key, this.themeModeNotifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = themeModeNotifier ?? themeModeNotifierGlobal;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            'PROFILE',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
              fontWeight: FontWeight.bold,
            ),
          ),
          SwitchListTile(
            value: notifier.value == ThemeMode.dark,
            onChanged: (val) {
              notifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
            title: Text(
              'Night Mode',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            activeColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withAlpha(127),
            inactiveTrackColor: theme.colorScheme.onSurface.withAlpha(51),
            inactiveThumbColor: theme.colorScheme.onSurface.withAlpha(127),
          ),
          SwitchListTile(
            value: true,
            onChanged: (_) {},
            title: Text(
              'Push Notification',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            activeColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withAlpha(127),
            inactiveTrackColor: theme.colorScheme.onSurface.withAlpha(51),
            inactiveThumbColor: theme.colorScheme.onSurface.withAlpha(127),
          ),
          SwitchListTile(
            value: false,
            onChanged: (_) {},
            title: Text(
              'Location',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            activeColor: theme.colorScheme.primary,
            activeTrackColor: theme.colorScheme.primary.withAlpha(127),
            inactiveTrackColor: theme.colorScheme.onSurface.withAlpha(51),
            inactiveThumbColor: theme.colorScheme.onSurface.withAlpha(127),
          ),
          ListTile(
            title: Text(
              'Language',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Text(
              'English',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(178),
              ),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Text(
            'OTHER',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
              fontWeight: FontWeight.bold,
            ),
          ),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withAlpha(85),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            title: Text(
              'Terms and Conditions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withAlpha(85),
            ),
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
