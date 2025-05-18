import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LabReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const LabReportsScreen({super.key, this.onBack});

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  int selectedTab = 0; // 0: Lab, 1: Radiology

  final List<Map<String, dynamic>> labReports = [
    {
      'title': 'Complete Blood Count (CBC)',
      'date': '02 Jan, 2024',
      'status': 'Pending',
      'result': '',
      'desc': 'Results will be 03 Jan, 2024',
      'statusColor': AppTheme.greyColor,
    },
    {
      'title': 'Complete Blood Count (CBC)',
      'date': '02 Jan, 2024',
      'status': 'Normal Results',
      'result': 'Normal Results',
      'desc': '',
      'statusColor': const Color(0xFF1A7C3E),
    },
    {
      'title': 'Lipid Panel',
      'date': '02 Jan, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': const Color(0xFFFFA800),
    },
    {
      'title': 'Thyroid Function Test',
      'date': '02 Jan, 2024',
      'status': 'Follow-Up Needed',
      'result': 'Follow-Up Needed',
      'desc': '',
      'statusColor': const Color(0xFFFF3B30),
    },
  ];

  final List<Map<String, dynamic>> radiologyReports = [
    {
      'title': 'Chest X-Ray',
      'date': '10 Feb, 2024',
      'status': 'Normal',
      'result': 'Normal',
      'desc': '',
      'statusColor': const Color(0xFF1A7C3E),
    },
    {
      'title': 'Abdominal Ultrasound',
      'date': '15 Feb, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': const Color(0xFFFFA800),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reports = selectedTab == 0 ? labReports : radiologyReports;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text('lab reports', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildTabs(theme),
            const SizedBox(height: 8),
            _buildSortAndFilter(theme),
            const SizedBox(height: 12),
            Expanded(
              child: reports.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildReportCard(report, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton('Lab Tests', 0, theme),
        const SizedBox(width: 12),
        _tabButton('Radiology', 1, theme),
      ],
    );
  }

  Widget _tabButton(String label, int index, ThemeData theme) {
    final bool selected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSortAndFilter(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.sort, size: 20, color: theme.colorScheme.onSurface.withAlpha(153)),
            const SizedBox(width: 4),
            Text('By date', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
          ],
        ),
        Icon(Icons.sync, size: 22, color: theme.colorScheme.onSurface.withAlpha(153)),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.shadowColor.withAlpha(20), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(report['title'], style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              ),
              Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withAlpha(153)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(report['date'], style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
              if (report['result'] != null && report['result'].toString().isNotEmpty) ...[
                const Text(' . '),
                Text(
                  report['result'],
                  style: theme.textTheme.bodyMedium?.copyWith(color: report['statusColor'], fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          if (report['desc'] != null && report['desc'].toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(report['desc'], style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.remove_red_eye, color: theme.colorScheme.primary),
                  label: Text('View Report', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download, color: theme.colorScheme.primary),
                  label: Text('Download', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.science, size: 60, color: theme.colorScheme.onSurface.withAlpha(153)),
          const SizedBox(height: 18),
          Text('No lab reports found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
          const SizedBox(height: 8),
          Text(
            'Your test reports will appear here\nonce they are available.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 