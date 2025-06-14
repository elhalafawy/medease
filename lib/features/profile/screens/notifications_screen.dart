import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../doctor/screens/doctor_details_screen.dart';
import '../../home/screens/medication_screen.dart';
import '../../appointment/screens/appointment_schedule_screen.dart';
import '../../home/screens/medical_record_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int newMedicalRecordCount = 1;
  int newMedicineCount = 1; // for future reminders
  final List<Map<String, dynamic>> favoriteDoctors = [
    {
      'name': 'Dr. Ahmed',
      'type': 'Neurologist',
      'image': 'assets/images/doctor_photo.png',
      'rating': '4.9',
      'reviews': '96',
      'hospital': 'Crist Hospital',
      'about': 'Dr. Ahmed is the top most Neurologist specialist in Crist Hospital in London, UK. He achieved several awards for his wonderful contribution.'
    },
    // يمكنك إضافة دكاترة مفضلين آخرين هنا
  ];

  int get newFavoriteCount => favoriteDoctors.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifications = [
      {
        'icon': Icons.calendar_month,
        'iconColor': theme.colorScheme.primary,
        'iconBg': theme.colorScheme.primaryContainer,
        'title': 'Schedules!',
        'subtitle': 'Check your schedule Today',
        'onTap': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AppointmentScheduleScreen(appointments: []),
            ),
          );
        },
        'badge': 0,
      },
      {
        'icon': Icons.favorite,
        'iconColor': theme.colorScheme.error,
        'iconBg': theme.colorScheme.errorContainer,
        'title': 'Favorites',
        'subtitle': 'See your favorite doctors',
        'onTap': (BuildContext context) {
          setState(() => favoriteDoctors.clear());
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _FavoritesWidget(
              doctors: favoriteDoctors,
              onDoctorTap: (doctor) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(doctor: doctor),
                  ),
                );
              },
            ),
          );
        },
        'badge': newFavoriteCount,
      },
      {
        'icon': Icons.medication,
        'iconColor': theme.colorScheme.tertiary,
        'iconBg': theme.colorScheme.tertiaryContainer,
        'title': 'Medicine',
        'subtitle': 'Check your schedule Today',
        'onTap': (BuildContext context) {
          setState(() => newMedicineCount = 0);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicationScreen(),
            ),
          );
        },
        'badge': newMedicineCount,
      },
      {
        'icon': Icons.folder,
        'iconColor': theme.colorScheme.secondary,
        'iconBg': theme.colorScheme.secondaryContainer,
        'title': 'Medical Record',
        'subtitle': 'View your medical records',
        'onTap': (BuildContext context) {
          setState(() => newMedicalRecordCount = 0);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicalRecordScreen(),
            ),
          );
        },
        'badge': newMedicalRecordCount,
      },
      {
        'icon': Icons.refresh,
        'iconColor': theme.colorScheme.primary,
        'iconBg': theme.colorScheme.primaryContainer,
        'title': 'App Update',
        'subtitle': 'Check your schedule Today',
        'onTap': (BuildContext context) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'App Update',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'You are already on the latest update.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'OK',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        'badge': 0,
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 22,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        itemCount: notifications.length,
        separatorBuilder: (context, i) => const SizedBox(height: 18),
        itemBuilder: (context, i) {
          final n = notifications[i];
          return Listener(
            behavior: HitTestBehavior.opaque,
            child: GestureDetector(
              onTap: n['onTap'] != null ? () => (n['onTap'] as void Function(BuildContext))(context) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: n['iconBg'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          n['icon'] as IconData,
                          color: n['iconColor'] as Color,
                          size: 24,
                        ),
                      ),
                      if ((n['badge'] as int) > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${n['badge']}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onError,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    n['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      n['subtitle'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoritesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> doctors;
  final void Function(Map<String, dynamic>) onDoctorTap;
  const _FavoritesWidget({required this.doctors, required this.onDoctorTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 22,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Favorites',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (doctors.isEmpty)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite doctors yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(doctor['image']),
                  ),
                  title: Text(
                    doctor['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    doctor['type'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  onTap: () => onDoctorTap(doctor),
                );
              },
            ),
        ],
      ),
    );
  }
}
