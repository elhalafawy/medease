import 'package:flutter/material.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/theme/app_theme.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic>)? onUpdate;
  final Function(String)? onCancel;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    this.onBack,
    this.onUpdate,
    this.onCancel,
  });

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool isUpdating = false;
  bool isCanceling = false;

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

      ].where((appointment) {
        return appointment['doctorName'].toString().toLowerCase().contains(query.toLowerCase()) ||
               appointment['specialty'].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _showUpdateDialog() {
    int selectedDayIndex = 2;
    int selectedTimeIndex = 0;
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
    List<String> dates = ['3', '4', '5', '6', '7'];
    List<String> times = ['9:00 AM', '9:30 AM', '10:00 AM', '10:30 AM'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Update Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(widget.appointment['imageUrl'] ?? widget.appointment['image']),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.appointment['doctorName'] ?? 'Dr. Ahmed',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              Text(
                                widget.appointment['specialty'] ?? 'Neurologist',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Appointment",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF232B3E)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(days.length, (index) {
                        final isSelected = index == selectedDayIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedDayIndex = index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF7DDCFF) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? const Color(0xFF7DDCFF) : Colors.grey.shade300, width: 2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                children: [
                                  Text(
                                    days[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF232B3E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    dates[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF232B3E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Available Time",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF232B3E)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(times.length, (index) {
                        final isSelected = index == selectedTimeIndex;
                        return GestureDetector(
                          onTap: () => setState(() => selectedTimeIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF5B183) : const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: isSelected ? const Color(0xFFF5B183) : Colors.grey.shade300),
                              boxShadow: isSelected
                                  ? [
                                      const BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Text(
                              times[index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF9C9C9C),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final updatedAppointment = Map<String, dynamic>.from(widget.appointment);
                            updatedAppointment['date'] = '${days[selectedDayIndex]} ${dates[selectedDayIndex]}';
                            updatedAppointment['time'] = times[selectedTimeIndex];
                            if (widget.onUpdate != null) {
                              widget.onUpdate!(updatedAppointment);
                            }
                            CustomSnackBar.show(
                              context: context,
                              message: 'Appointment updated successfully',
                            );
                            Navigator.pop(context); // Close the update dialog
                            Navigator.pop(context); // Return to schedule screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14375A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Update appointment status to Canceled
              final updatedAppointment = Map<String, dynamic>.from(widget.appointment);
              updatedAppointment['status'] = 'Canceled';

              if (widget.onCancel != null) {
                widget.onCancel!(widget.appointment['id']);
              }
              if (widget.onUpdate != null) {
                widget.onUpdate!(updatedAppointment);
              }

              CustomSnackBar.show(
                context: context,
                message: 'Appointment cancelled successfully',
              );
              Navigator.pop(context); // Return to schedule screen
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.appBarBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (widget.appointment['status'] == 'Pending' || widget.appointment['status'] == 'Confirmed')
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
              onPressed: _showUpdateDialog,
            ),
          if (widget.appointment['status'] == 'Pending' || widget.appointment['status'] == 'Confirmed')
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: _showCancelDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(widget.appointment['imageUrl'] ?? widget.appointment['image']),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.appointment['doctorName'] ?? 'Dr. Ahmed',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            Text(
                              widget.appointment['specialty'] ?? 'Senior Neurologist and Surgeon',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn(
                          Icons.calendar_today,
                          'Date',
                          widget.appointment['date'] ?? 'Mon 4',
                        ),
                        _buildInfoColumn(
                          Icons.access_time,
                          'Time',
                          widget.appointment['time'] ?? '9:00 AM',
                        ),
                        _buildInfoColumn(
                          Icons.location_on,
                          'Location',
                          widget.appointment['location'] ?? 'Medical Center',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.appointment['status'] ?? 'Pending').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.appointment['status'] ?? 'Pending',
                            style: TextStyle(
                              color: _getStatusColor(widget.appointment['status'] ?? 'Pending'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (widget.appointment['status'] == 'Pending' || widget.appointment['status'] == 'Confirmed')
                          ElevatedButton(
                            onPressed: _showUpdateDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Update'),
                          ),
                        if (widget.appointment['status'] == 'Pending' || widget.appointment['status'] == 'Confirmed')
                          const SizedBox(width: 6),
                        if (widget.appointment['status'] == 'Pending' || widget.appointment['status'] == 'Confirmed')
                          ElevatedButton(
                            onPressed: _showCancelDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Additional Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
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
                        _buildInfoRow('Patient Name', widget.appointment['patientName'] ?? 'Ahmed Elhaafawy'),
                        const Divider(),
                        _buildInfoRow('Phone Number', widget.appointment['phone'] ?? '01150504999'),
                        const Divider(),
                        _buildInfoRow('Email', widget.appointment['email'] ?? 'Ahmed.elhalafawy@gmail.com'),
                        const Divider(),
                        _buildInfoRow('Notes', widget.appointment['notes'] ?? 'No additional notes'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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
