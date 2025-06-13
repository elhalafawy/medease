import 'package:flutter/material.dart';
import 'doctor_details_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorsScreen extends StatefulWidget {
  final String category;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onDoctorTap;

  const DoctorsScreen({
    super.key,
    required this.category,
    this.onBack,
    this.onDoctorTap,
  });

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Map<String, dynamic>> doctors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
    print(doctors);
  }

  Future<void> fetchDoctors() async {
    final response = await Supabase.instance.client
        .from('doctors')
        .select('*');
    setState(() {
      doctors = List<Map<String, dynamic>>.from(response);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Doctors',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: theme.colorScheme.onSurface),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return _buildDoctorCard(context, doctor);
              },
            ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Map<String, dynamic> doctor) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (widget.onDoctorTap != null) {
          widget.onDoctorTap!(doctor);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailsScreen(
                doctor: doctor,
                onBack: () => Navigator.pop(context),
                onBookAppointment: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/appointment', arguments: doctor);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.asset(
                doctor['image'] ?? 'assets/images/doctor_photo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'] ?? '-',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doctor['type'] ?? '-',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600], size: 16),
                              const SizedBox(width: 2),
                              Text(
                                '${(doctor['rating'] as num?)?.toDouble().toStringAsFixed(1) ?? '-'}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor['hospital'] ?? '-',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                doctor['price'] ?? '-',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 4),
                              Text(
                                doctor['available'] ?? doctor['availability'] ?? 'available',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> fetchDoctorDetails(String doctorId) async {
  final response = await Supabase.instance.client
      .from('doctors')
      .select('*')
      // .eq('doctor_id', doctorId)
      .single();
  return response;
}
