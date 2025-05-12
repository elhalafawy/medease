import 'package:flutter/material.dart';
import '../../appointment/screens/appointment_screen.dart';
import '../../../core/theme/app_theme.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback? onBack;
  final VoidCallback? onBookAppointment;

  const DoctorDetailsScreen({
    super.key,
    required this.doctor,
    this.onBack,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Doctor Details',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
          children: [
          // Doctor image at the top
          Container(
                width: double.infinity,
            height: 260,
            color: AppTheme.backgroundColor,
                child: Image.asset(
                  doctor['image'],
                  fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // Floating DraggableScrollableSheet
          DraggableScrollableSheet(
            initialChildSize: 0.68,
            minChildSize: 0.68,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
              ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'],
                                style: AppTheme.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                              const SizedBox(height: 2),
                  Text(
                    doctor['type'],
                                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textColor.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
                        const Icon(Icons.star, color: Color(0xFFF5B100), size: 22),
                        const SizedBox(width: 4),
                        Text(
                          doctor['rating'],
                          style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                        Text(
                          ' (${doctor['reviews']} reviews)',
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textColor.withOpacity(0.6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      doctor['hospital'],
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textColor.withOpacity(0.7)),
            ),
                    const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                        _StatCircle(icon: Icons.person, value: doctor['patients'], label: 'Patients'),
                        _StatCircle(icon: Icons.verified_user, value: doctor['experience'], label: 'Years'),
                        _StatCircle(icon: Icons.star_border, value: doctor['rating'], label: 'Rating'),
                        _StatCircle(icon: Icons.chat, value: doctor['reviews'], label: 'Reviews'),
              ],
            ),
            const SizedBox(height: 24),
                    Text('About Me', style: AppTheme.titleLarge.copyWith(color: AppTheme.primaryColor)),
                    const SizedBox(height: 8),
                    _AboutMeSection(about: doctor['about'] ?? 'No information.'),
                    const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentScreen(
                        doctor: doctor,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
              ),
            ),
          ),
          // Favorite icon floating over image
          Positioned(
            top: 36,
            right: 32,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.favorite_border, color: AppTheme.primaryColor),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCircle extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCircle({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

class _AboutMeSection extends StatefulWidget {
  final String about;
  const _AboutMeSection({required this.about});
  @override
  State<_AboutMeSection> createState() => _AboutMeSectionState();
}

class _AboutMeSectionState extends State<_AboutMeSection> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final maxLines = expanded ? null : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.about,
          maxLines: maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textColor.withOpacity(0.85)),
        ),
        if (!expanded && widget.about.length > 60)
          TextButton(
            onPressed: () => setState(() => expanded = true),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
            child: const Text('Read More...', style: TextStyle(color: AppTheme.primaryColor)),
        ),
      ],
    );
  }
}
