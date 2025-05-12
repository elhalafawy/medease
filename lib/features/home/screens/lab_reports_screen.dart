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
      'statusColor': Color(0xFF1A7C3E),
    },
    {
      'title': 'Lipid Panel',
      'date': '02 Jan, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': Color(0xFFFFA800),
    },
    {
      'title': 'Thyroid Function Test',
      'date': '02 Jan, 2024',
      'status': 'Follow-Up Needed',
      'result': 'Follow-Up Needed',
      'desc': '',
      'statusColor': Color(0xFFFF3B30),
    },
  ];

  final List<Map<String, dynamic>> radiologyReports = [
    {
      'title': 'Chest X-Ray',
      'date': '10 Feb, 2024',
      'status': 'Normal',
      'result': 'Normal',
      'desc': '',
      'statusColor': Color(0xFF1A7C3E),
    },
    {
      'title': 'Abdominal Ultrasound',
      'date': '15 Feb, 2024',
      'status': 'Requires Attention',
      'result': 'Requires Attention',
      'desc': '',
      'statusColor': Color(0xFFFFA800),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final reports = selectedTab == 0 ? labReports : radiologyReports;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.appBarBackgroundColor,
        elevation: 0,
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
        centerTitle: true,
        title: const Text('lab reports', style: AppTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 8),
            _buildSortAndFilter(),
            const SizedBox(height: 12),
            Expanded(
              child: reports.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return _buildReportCard(report);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabButton('Lab Tests', 0),
        const SizedBox(width: 12),
        _tabButton('Radiology', 1),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final bool selected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor),
        ),
        child: Text(
          label,
          style: AppTheme.bodyLarge.copyWith(
            color: selected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSortAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.sort, size: 20, color: AppTheme.greyColor),
            const SizedBox(width: 4),
            Text('By date', style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          ],
        ),
        Icon(Icons.sync, size: 22, color: AppTheme.greyColor),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(report['title'], style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
              ),
              Icon(Icons.more_vert, color: AppTheme.greyColor),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(report['date'], style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
              if (report['result'] != null && report['result'].toString().isNotEmpty) ...[
                const Text(' . '),
                Text(
                  report['result'],
                  style: AppTheme.bodyMedium.copyWith(color: report['statusColor'], fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
          if (report['desc'] != null && report['desc'].toString().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(report['desc'], style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, color: AppTheme.primaryColor),
                  label: Text('View Report', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, color: AppTheme.primaryColor),
                  label: Text('Download', style: AppTheme.bodyLarge.copyWith(color: AppTheme.primaryColor)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.science, size: 60, color: AppTheme.greyColor),
          const SizedBox(height: 18),
          Text('No lab reports found', style: AppTheme.bodyLarge.copyWith(color: AppTheme.greyColor)),
          const SizedBox(height: 8),
          Text(
            'Your test reports will appear here\nonce they are available.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 