import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DoctorNotificationsScreen extends StatelessWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'icon': Icons.calendar_month,
        'iconColor': const Color(0xFF2563EB),
        'iconBg': const Color(0xFFE8F1FB),
        'title': '3 Schedules!',
        'subtitle': 'Check your schedule Today',
      },
      {
        'icon': Icons.chat,
        'iconColor': const Color(0xFFEA4E6D),
        'iconBg': const Color(0xFFFDE8ED),
        'title': '14 Messages',
        'subtitle': 'Check your schedule Today',
      },
      {
        'icon': Icons.medication,
        'iconColor': const Color(0xFFF5B100),
        'iconBg': const Color(0xFFFFF7E6),
        'title': 'Medicine',
        'subtitle': 'Check your schedule Today',
      },
      {
        'icon': Icons.vaccines,
        'iconColor': const Color(0xFF22D3EE),
        'iconBg': const Color(0xFFE6F9FB),
        'title': 'Vaccine Update',
        'subtitle': 'Check your schedule Today',
      },
      {
        'icon': Icons.refresh,
        'iconColor': const Color(0xFFB91C1C),
        'iconBg': const Color(0xFFFDE8ED),
        'title': 'App Update',
        'subtitle': 'Check your schedule Today',
      },
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications', style: AppTheme.headlineMedium),
        centerTitle: false,
        foregroundColor: AppTheme.textColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        itemCount: notifications.length,
        separatorBuilder: (context, i) => const SizedBox(height: 18),
        itemBuilder: (context, i) {
          final n = notifications[i];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE5EAF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: n['iconBg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(n['icon'] as IconData, color: n['iconColor'] as Color, size: 28),
              ),
              title: Text(
                n['title'] as String,
                style: AppTheme.titleLarge,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  n['subtitle'] as String,
                  style: AppTheme.bodyMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
