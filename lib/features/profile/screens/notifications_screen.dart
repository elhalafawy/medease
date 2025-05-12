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
    final notifications = [
      {
        'icon': Icons.calendar_month,
        'iconColor': AppTheme.notifCalendarIcon,
        'iconBg': AppTheme.notifCalendarBg,
        'title': 'Schedules!',
        'subtitle': 'Check your schedule Today',
        'onTap': (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentScheduleScreen(appointments: const []),
            ),
          );
        },
        'badge': 0,
      },
      {
        'icon': Icons.favorite,
        'iconColor': AppTheme.notifChatIcon,
        'iconBg': AppTheme.notifChatBg,
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
        'iconColor': AppTheme.notifMedicineIcon,
        'iconBg': AppTheme.notifMedicineBg,
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
        'iconColor': AppTheme.notifVaccineIcon,
        'iconBg': AppTheme.notifVaccineBg,
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
        'iconColor': AppTheme.notifUpdateIcon,
        'iconBg': AppTheme.notifUpdateBg,
        'title': 'App Update',
        'subtitle': 'Check your schedule Today',
        'onTap': (BuildContext context) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('App Update'),
              content: const Text('You are already on the latest update.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        'badge': 0,
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
          return GestureDetector(
            onTap: n['onTap'] != null ? () => (n['onTap'] as void Function(BuildContext))(context) : null,
            child: Container(
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
                          backgroundColor: Colors.red,
                          child: Text(
                            '${n['badge']}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
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
              const Text('Favorites', style: AppTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 24),
          ...doctors.map((doctor) => GestureDetector(
                onTap: () => onDoctorTap(doctor),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(doctor['image']),
                      radius: 28,
                    ),
                    title: Text(doctor['name'], style: AppTheme.titleLarge),
                    subtitle: Text(doctor['type'], style: AppTheme.bodyMedium),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
