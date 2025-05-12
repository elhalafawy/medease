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
      backgroundColor: AppTheme.notifPageBg,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
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
              border: Border.all(color: AppTheme.notifCardBorder),
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
                  color: _getNotifBgColor(i),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getNotifIcon(i), color: _getNotifIconColor(i), size: 28),
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

  Color _getNotifIconColor(int i) {
    switch (i) {
      case 0:
        return AppTheme.notifCalendarIcon;
      case 1:
        return AppTheme.notifChatIcon;
      case 2:
        return AppTheme.notifMedicineIcon;
      case 3:
        return AppTheme.notifVaccineIcon;
      case 4:
        return AppTheme.notifUpdateIcon;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getNotifBgColor(int i) {
    switch (i) {
      case 0:
        return AppTheme.notifCalendarBg;
      case 1:
        return AppTheme.notifChatBg;
      case 2:
        return AppTheme.notifMedicineBg;
      case 3:
        return AppTheme.notifVaccineBg;
      case 4:
        return AppTheme.notifUpdateBg;
      default:
        return Colors.white;
    }
  }

  IconData _getNotifIcon(int i) {
    switch (i) {
      case 0:
        return Icons.calendar_month;
      case 1:
        return Icons.chat;
      case 2:
        return Icons.medication;
      case 3:
        return Icons.vaccines;
      case 4:
        return Icons.refresh;
      default:
        return Icons.notifications;
    }
  }
}
