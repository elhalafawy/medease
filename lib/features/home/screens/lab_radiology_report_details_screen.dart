import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:cached_network_image/cached_network_image.dart'; // Import for caching network images

class LabRadiologyReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const LabRadiologyReportDetailsScreen({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Safely access data from the reportData map
    final String title = reportData['Title'] ?? 'N/A';
    final String date = reportData['created_at'] != null
        ? DateFormat('dd MMM, yyyy').format(DateTime.parse(reportData['created_at']).toLocal())
        : 'N/A';
    final String status = reportData['status'] ?? 'N/A';
    final String doctorName = reportData['doctors']?['name'] ?? 'N/A';
    // Access the report_url
    final String? reportUrl = reportData['report_url'];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Report Details',
          style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Report Title',
              value: title,
              icon: Icons.description_outlined,
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Date',
              value: date,
              icon: Icons.calendar_today_outlined,
              theme: theme,
            ),
            const SizedBox(height: 16),
             _buildInfoCard(
              title: 'Status',
              value: status,
              icon: Icons.info_outline,
              theme: theme,
               valueColor: _getStatusColor(status, theme), // Pass status color
            ),
            const SizedBox(height: 16),
             _buildInfoCard(
              title: 'Added By Doctor',
              value: doctorName,
              icon: Icons.person_outline,
              theme: theme,
            ),
            // Add more _buildInfoCard widgets for other report details if available

            // Display the uploaded image if reportUrl exists
            if (reportUrl != null && reportUrl.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Uploaded File:',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Center( // Center the image
                child: CachedNetworkImage( // Use CachedNetworkImage for better performance
                  imageUrl: reportUrl,
                  placeholder: (context, url) => CircularProgressIndicator(), // Placeholder while loading
                  errorWidget: (context, url, error) => Icon(Icons.error), // Error widget if image fails to load
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

   Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Normal Results':
        return Colors.green;
      case 'Requires Attention':
        return Colors.orange;
      case 'Urgent':
        return Colors.red;
      default:
        return theme.colorScheme.onSurface.withOpacity(0.7); // Default color
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(color: valueColor ?? theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }
} 