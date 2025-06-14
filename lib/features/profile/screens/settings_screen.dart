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
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Text(
            'PROFILE',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: notifier.value == ThemeMode.dark,
                  onChanged: (val) {
                    notifier.value = val ? ThemeMode.dark : ThemeMode.light;
                  },
                  title: Text(
                    'Night Mode',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Enable dark mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primaryContainer,
                  inactiveTrackColor: theme.colorScheme.surfaceVariant,
                  inactiveThumbColor: theme.colorScheme.outline,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: Text(
                    'Push Notifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Receive notifications about appointments and updates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primaryContainer,
                  inactiveTrackColor: theme.colorScheme.surfaceVariant,
                  inactiveThumbColor: theme.colorScheme.outline,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                SwitchListTile(
                  value: false,
                  onChanged: (_) {},
                  title: Text(
                    'Location Services',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Allow app to access your location',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  activeColor: theme.colorScheme.primary,
                  activeTrackColor: theme.colorScheme.primaryContainer,
                  inactiveTrackColor: theme.colorScheme.surfaceVariant,
                  inactiveThumbColor: theme.colorScheme.outline,
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                ListTile(
                  title: Text(
                    'Language',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Change app language',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'English',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'OTHER',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Privacy Policy',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Read our privacy policy',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
                ListTile(
                  title: Text(
                    'Terms and Conditions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Read our terms and conditions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final ValueNotifier<ThemeMode> themeModeNotifierGlobal = themeModeNotifier;
