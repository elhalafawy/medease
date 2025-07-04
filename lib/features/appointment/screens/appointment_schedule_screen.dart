import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'appointment_details_screen.dart';
import '../../profile/screens/notifications_screen.dart';
import 'package:intl/intl.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onSelectAppointment;
  final List<Map<String, dynamic>>? appointments;

  const AppointmentScheduleScreen({
    super.key,
    this.onBack,
    this.onSelectAppointment,
    this.appointments,
  });

  @override
  State<AppointmentScheduleScreen> createState() => _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  String selectedTab = 'Upcoming';
  String? _error;
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.appointments == null) {
      _appointments = widget.appointments!;
      _loading = false;
      // loadAppointments();
    } else {
      loadAppointments();
    }
  }

  Future<void> loadAppointments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Get the current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _error = 'User not logged in';
          _loading = false;
        });
        return;
      }

      // Get the patient_id for the current user
      final patientResponse = await Supabase.instance.client
          .from('patients')
          .select('patient_id')
          .eq('user_id', user.id)
          .single();

      final patientId = patientResponse['patient_id'];

      // Fetch appointments for this patient
      final response = await Supabase.instance.client
          .from('appointments')
          .select('*')
          .eq('patient_id', patientId)
          .order('date', ascending: true)
          .order("time", ascending: true); // Filter by patient_id

      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
      // _appointments = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments';
        _loading = false;
      });
      print('Error loading appointments: $e');
    }
  }

  void _updateAppointment(Map<String, dynamic> updatedAppointment) {
    setState(() {
      final index = _appointments.indexWhere((a) => a['appointment_id'] == updatedAppointment['appointment_id']);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      }
    });
  }


  Future<void> _cancelAppointment(String appointmentId) async {
    await Supabase.instance.client
        .from('appointments')
        .update({'status': 'cancelled'})
        .eq('appointment_id', appointmentId);

    setState(() {
      final index = _appointments.indexWhere((a) => a['appointment_id'] == appointmentId);
      if (index != -1) {
        _appointments[index]['status'] = 'cancelled';
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
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatTimeTo12Hour(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final dt = DateTime(0, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredAppointments = _appointments.where((appointment) {
      final status = (appointment['status'] ?? '').toString().toLowerCase();
      final doctorName = (appointment['doctorName'] ?? '').toString().toLowerCase();
      final specialty = (appointment['specialty'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      bool matchesSearch = true;
      if (_isSearching && query.isNotEmpty) {
        matchesSearch = doctorName.contains(query) || specialty.contains(query);
      }

      switch (selectedTab) {
        case 'Upcoming':
          return matchesSearch && (status == 'pending' || status == 'confirmed');
        case 'Completed':
          return matchesSearch && status == 'completed';
        case 'Canceled':
          return matchesSearch && (status == 'cancelled' || status == 'canceled');
        default:
          return matchesSearch;
      }
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search appointments...', 
                  border: InputBorder.none,
                  hintStyle: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text(
                'Appointment Schedule',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: theme.colorScheme.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.red,
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: theme.textTheme.bodyLarge))
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTabs(theme),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filteredAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 64, color: theme.colorScheme.onSurface.withAlpha(80)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No ${selectedTab.toLowerCase()} appointments',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface.withAlpha(160),
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
                                return _buildAppointmentCard(filteredAppointments[index], theme);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    List<String> tabs = ['Upcoming', 'Completed', 'Canceled'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, ThemeData theme) {
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(20),
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
                  border: Border.all(color: theme.colorScheme.primary, width: 1),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage(
                    appointment['imageUrl'] ?? appointment['image'] ?? 'assets/images/doctor_photo.png',
                  ),
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
                            appointment['doctorName'] ?? 'Dr. Ahmed Essmat',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(appointment['status'] ?? 'pending').withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment['status'] ?? 'pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(appointment['status'] ?? 'pending'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['specialty'] ?? 'Senior Neurologist and Surgeon',
                      style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          appointment['date'] ?? 'Mon 4',
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          (() {
                            final t = appointment['time'];
                            if (t is String && t.length >= 5) {
                              final timeStr = t.endsWith(':00') ? t.substring(0,5) : t;
                              return formatTimeTo12Hour(timeStr);
                            }
                            return t ?? '9:00 AM';
                          })(),
                          style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.medical_services_outlined, size: 16, color: theme.colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          'Type: ' + ((appointment['type'] ?? 'consultation')
                            .toString()
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
                            .join(' ')),
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
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
