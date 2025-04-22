import 'package:flutter/material.dart';
import 'appointment_details_screen.dart';

class AppointmentScheduleScreen extends StatefulWidget {
  const AppointmentScheduleScreen({super.key});

  @override
  State<AppointmentScheduleScreen> createState() => _AppointmentScheduleScreenState();
}

class _AppointmentScheduleScreenState extends State<AppointmentScheduleScreen> {
  String selectedTab = 'Upcoming';

  List<Map<String, dynamic>> appointments = [
    {
      'name': 'Dr. Ahmed',
      'type': 'Neurologist',
      'hospital': 'Cairo Hospital',
      'date': '6 Jun, Sun',
      'time': '10:30am - 11:30pm',
      'status': 'Confirmed',
      'rating': 4.8,
      'price': '25.00 EGP',
      'message': 'Please be on time.',
      'image': 'https://placehold.co/100x100',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Appointment Schedule',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF32384B)),
        ),
        actions: const [
          Icon(Icons.search, color: Colors.black),
          SizedBox(width: 10),
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabs(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return _buildAppointmentCard(appointments[index]);
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
        color: const Color(0xFFE8F3F1),
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
                  color: isSelected ? const Color(0xFF022E5B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  tab,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF101623),
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailsScreen(
              doctorName: appointment['name'],
              specialty: appointment['type'],
              hospital: appointment['hospital'],
              imageUrl: appointment['image'],
              rating: appointment['rating'],
              price: appointment['price'],
              date: appointment['date'],
              time: appointment['time'],
              message: appointment['message'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8F3F1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(appointment['image']),
                  radius: 23,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      appointment['type'],
                      style: const TextStyle(fontSize: 12, color: Color(0xFFADADAD), fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF555555)),
                const SizedBox(width: 6),
                Text(appointment['date'], style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF555555)),
                const SizedBox(width: 6),
                Text(appointment['time'], style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.circle, size: 8, color: Color(0xFF7AEA78)),
                const SizedBox(width: 6),
                Text(appointment['status'], style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE8F3F1)),
                      backgroundColor: const Color(0xFFE8F3F1),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF555555), fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF022E5B),
                    ),
                    child: const Text('Reschedule', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
