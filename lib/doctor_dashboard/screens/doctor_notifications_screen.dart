import 'package:flutter/material.dart';

class DoctorNotificationsScreen extends StatefulWidget {
  final int appointmentsCount;
  const DoctorNotificationsScreen({super.key, required this.appointmentsCount});

  @override
  State<DoctorNotificationsScreen> createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends State<DoctorNotificationsScreen> {
  late int newSchedules;
  int newMessages = 14;
  int newMedicine = 1;
  int newVaccine = 0;
  int newUpdate = 0;

  @override
  Widget build(BuildContext context) {
    newSchedules = widget.appointmentsCount;
    final notifications = [
      {
        'icon': Icons.calendar_month,
        'iconColor': Theme.of(context).colorScheme.primary,
        'iconBg': Theme.of(context).colorScheme.primary.withOpacity(0.1),
        'title': '${widget.appointmentsCount} Schedules!',
        'subtitle': 'Check your schedule Today',
        'badge': widget.appointmentsCount,
      },
      {
        'icon': Icons.chat,
        'iconColor': Theme.of(context).colorScheme.secondary,
        'iconBg': Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        'title': '14 Messages',
        'subtitle': 'Check your schedule Today',
        'badge': newMessages,
      },
      {
        'icon': Icons.medication,
        'iconColor': Theme.of(context).colorScheme.tertiary,
        'iconBg': Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
        'title': 'Medicine',
        'subtitle': 'Check your schedule Today',
        'badge': newMedicine,
      },
      {
        'icon': Icons.vaccines,
        'iconColor': Theme.of(context).colorScheme.primaryContainer,
        'iconBg': Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
        'title': 'Vaccine Update',
        'subtitle': 'Check your schedule Today',
        'badge': newVaccine,
      },
      {
        'icon': Icons.refresh,
        'iconColor': Theme.of(context).colorScheme.error,
        'iconBg': Theme.of(context).colorScheme.error.withOpacity(0.08),
        'title': 'App Update',
        'subtitle': 'Check your schedule Today',
        'badge': newUpdate,
      },
    ];
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifications', style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface)),
        centerTitle: false,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 22, color: theme.colorScheme.onSurface),
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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
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
              leading: Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: n['iconBg'] as Color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(n['icon'] as IconData, color: n['iconColor'] as Color, size: 28),
                  ),
                  if ((n['badge'] as int) > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: theme.colorScheme.error,
                        child: Text(
                          '${n['badge']}',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onError),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                n['title'] as String,
                style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  n['subtitle'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
        return Theme.of(context).colorScheme.primary;
      case 1:
        return Theme.of(context).colorScheme.secondary;
      case 2:
        return Theme.of(context).colorScheme.tertiary;
      case 3:
        return Theme.of(context).colorScheme.primaryContainer;
      case 4:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getNotifBgColor(int i) {
    switch (i) {
      case 0:
        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
      case 1:
        return Theme.of(context).colorScheme.secondary.withOpacity(0.1);
      case 2:
        return Theme.of(context).colorScheme.tertiary.withOpacity(0.1);
      case 3:
        return Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15);
      case 4:
        return Theme.of(context).colorScheme.error.withOpacity(0.08);
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
