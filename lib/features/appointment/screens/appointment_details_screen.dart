import 'package:flutter/material.dart';
import '../../../core/widgets/custom_snackbar.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onBack;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.onBack,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  void _handleSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    // Simulate search functionality
    setState(() {
      _isSearching = true;
      _searchResults = [
        {
          'doctorName': 'Dr. Ahmed',
          'specialty': 'Senior Neurologist and Surgeon',
          'date': 'Mon 4',
          'time': '9:00 AM',
          'status': 'Pending',
          'imageUrl': 'assets/images/doctor_photo.png',
        },
        {
          'doctorName': 'Dr. Sarah',
          'specialty': 'Cardiologist',
          'date': 'Tue 5',
          'time': '10:30 AM',
          'status': 'Confirmed',
          'imageUrl': 'assets/images/doctor_photo.png',
        },
      ].where((appointment) {
        return appointment['doctorName'].toString().toLowerCase().contains(query.toLowerCase()) ||
               appointment['specialty'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF32384B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Appointments'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by doctor name or specialty',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: _handleSearch,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _searchController.clear();
                        setState(() {
                          _isSearching = false;
                          _searchResults = [];
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              CustomSnackBar.show(
                context: context,
                message: 'No new notifications',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSearching
          ? _buildSearchResults()
          : _buildAppointmentDetails(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('No appointments found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final appointment = _searchResults[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppointmentCard(widget.appointment),
          const SizedBox(height: 24),
          const Text(
            'Appointment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Date', widget.appointment['date']),
          _buildInfoRow('Time', widget.appointment['time']),
          _buildInfoRow('Status', widget.appointment['status']),
          const SizedBox(height: 24),
          const Text(
            'Doctor Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Name', widget.appointment['doctorName']),
          _buildInfoRow('Specialty', widget.appointment['specialty']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[300],
                backgroundImage: AssetImage(appointment['imageUrl']),
                radius: 23,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['specialty'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFADADAD),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment['status']).withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  appointment['status'],
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(appointment['status']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF555555)),
              const SizedBox(width: 6),
              Text(
                appointment['date'],
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF555555)),
              const SizedBox(width: 6),
              Text(
                appointment['time'],
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
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
}
