import 'package:flutter/material.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/theme/app_theme.dart';
import 'appointment_details_screen.dart';
import '../../profile/screens/notifications_screen.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  final List<Map<String, dynamic>> appointments;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onSelectAppointment;
  const AppointmentScheduleScreen({super.key, required this.appointments, this.onBack, this.onSelectAppointment});

  @override
  State<AppointmentScheduleScreen> createState() => _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  String selectedTab = 'Upcoming';
  late List<Map<String, dynamic>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = List.from(widget.appointments);
  }

  void _updateAppointment(Map<String, dynamic> updatedAppointment) {
    setState(() {
      final index = _appointments.indexWhere((a) => a['id'] == updatedAppointment['id']);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
    });
  }

  void _cancelAppointment(String appointmentId) {
    setState(() {
      final index = _appointments.indexWhere((a) => a['id'] == appointmentId);
      if (index != -1) {
        _appointments[index]['status'] = 'Canceled';
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter appointments based on selected tab
    final filteredAppointments = _appointments.where((appointment) {
      switch (selectedTab) {
        case 'Upcoming':
          return appointment['status'] == 'Pending' || appointment['status'] == 'Confirmed';
        case 'Completed':
          return appointment['status'] == 'Completed';
        case 'Canceled':
          return appointment['status'] == 'Canceled';
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Appointment Schedule',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
          IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.primaryColor),
            onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.red,
                  child: Text(
                    '1', // عدد الإشعارات (مثلاً تأكيد الحجز)
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${selectedTab.toLowerCase()} appointments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(filteredAppointments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    List<String> tabs = ['Upcoming', 'Completed', 'Canceled'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: tabs.map((tab) {
          bool isSelected = tab == selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = tab),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppTheme.textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () {
        if (widget.onSelectAppointment != null) {
          widget.onSelectAppointment!(appointment);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(
                appointment: appointment,
                onBack: () => Navigator.pop(context),
                onUpdate: _updateAppointment,
                onCancel: _cancelAppointment,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor, width: 1),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage(appointment['imageUrl'] ?? appointment['image']),
                  radius: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment['doctorName'] ?? 'Dr. Ahmed',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment['status'] ?? 'Pending').withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment['status'] == 'Canceled' ? 'Canceled' : appointment['status'] ?? 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(appointment['status'] ?? 'Pending'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['specialty'] ?? 'Senior Neurologist and Surgeon',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          appointment['date'] ?? 'Mon 4',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 6),
                        Text(
                          appointment['time'] ?? '9:00 AM',
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

