import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.black),
  onPressed: () {
    Navigator.pop(context);

          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationCard(
            icon: Icons.calendar_today,
            title: 'Schedules',
            subtitle: 'Check your schedule Today',
            color: const Color(0xFFE1ECFF),
          ),
          _buildNotificationCard(
            icon: Icons.medication,
            title: 'Medicine',
            subtitle: 'Check your schedule Today',
            color: const Color(0xFFFFF1CE),
          ),
          _buildNotificationCard(
            icon: Icons.vaccines,
            title: 'Vaccine Update',
            subtitle: 'Check your schedule Today',
            color: const Color(0xFFE4F9FF),
          ),
          _buildNotificationCard(
            icon: Icons.update,
            title: 'App Update',
            subtitle: 'Check your schedule Today',
            color: const Color(0xFFF5E6EB),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
