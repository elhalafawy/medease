import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:intl/intl.dart'; // Import for date formatting
import 'lab_radiology_report_details_screen.dart'; // Import the new details screen
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LabReportsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const LabReportsScreen({super.key, this.onBack});

  @override
  State<LabReportsScreen> createState() => _LabReportsScreenState();
}

class _LabReportsScreenState extends State<LabReportsScreen> {
  final SupabaseClient _supabase = Supabase.instance.client; // Supabase client instance
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _labReports = []; // List for lab reports
  List<Map<String, dynamic>> _radiologyReports = []; // List for radiology reports
  bool _isLoading = true; // Loading state
  int _selectedCategory = 0; // 0 for Lab Tests, 1 for Radiology

  @override
  void initState() {
    super.initState();
    _loadReports(); // Load data on init
  }

  Future<void> _loadReports() async {
    try {
      setState(() => _isLoading = true);
      
      // Fetch Lab Reports
      final labResponse = await _supabase
          .from('lab_reports')
          .select('report_id, patient_id, doctor_id, status, created_at, Title, doctors!lab_reports_doctor_id_fkey(name)')
          .order('created_at', ascending: false);

      // Fetch Radiology Reports
      final radiologyResponse = await _supabase
          .from('Radiology') // Assuming your radiology table is named 'Radiology'
          .select('Radiology_id, patient_id, doctor_id, status, created_at, Title, doctors!Radiology_doctor_id_fkey(name)') // Select necessary columns and join with doctors table
          .order('created_at', ascending: false);

      setState(() {
        _labReports = List<Map<String, dynamic>>.from(labResponse);
        _radiologyReports = List<Map<String, dynamic>>.from(radiologyResponse);
        _isLoading = false;
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage(Map<String, dynamic> report) async {
    try {
      // Show bottom sheet for picking source
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // Pick the image
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload to Supabase Storage
      final String fileExt = image.path.split('.').last;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      // Construct the file path using patient_id, report type, and report ID
      final String reportType = _selectedCategory == 0 ? 'lab' : 'radiology';
      // Ensure report_id or Radiology_id is not null before converting to string
      final String reportId = _selectedCategory == 0 
          ? (report['report_id']?.toString() ?? 'unknown_report')
          : (report['Radiology_id']?.toString() ?? 'unknown_radiology');
      // Ensure patient_id is not null before converting to string
      final String patientId = report['patient_id']?.toString() ?? 'unknown_patient';

      final String filePath = '$patientId/$reportType/$reportId/$fileName';

      // Upload file to the 'labreports' bucket
      final File imageFile = File(image.path);
      await _supabase.storage.from('labreports').upload(filePath, imageFile);

      // Get public URL from the 'labreports' bucket
      final String imageUrl = _supabase.storage.from('labreports').getPublicUrl(filePath);

      // Update the report in the database with the image URL
      final String tableName = _selectedCategory == 0 ? 'lab_reports' : 'Radiology';
      final String idField = _selectedCategory == 0 ? 'report_id' : 'Radiology_id';
      
      await _supabase
          .from(tableName)
          .update({'report_url': imageUrl})
          .eq(idField, report[idField]);

      // Refresh the reports
      await _loadReports();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading report: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: Text('Lab Tests & Radiology', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)), // Updated title
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildCategoryButtons(theme), // Add category buttons
            Expanded(
              child: Builder(
                builder: (BuildContext context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (_selectedCategory == 0) {
                    // Lab Reports
                    if (_labReports.isEmpty) {
                      return _buildEmptyState(theme);
                    } else {
                      return ListView.builder(
                        itemCount: _labReports.length,
                        itemBuilder: (context, index) {
                          final report = _labReports[index];
                          return _buildReportCard(report, theme);
                        },
                      );
                    }
                  } else {
                    // Radiology Reports
                    if (_radiologyReports.isEmpty) {
                      return _buildEmptyState(theme);
                    } else {
                      return ListView.builder(
                        itemCount: _radiologyReports.length,
                        itemBuilder: (context, index) {
                          final report = _radiologyReports[index];
                          return _buildReportCard(report, theme);
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New widget to build the category buttons
  Widget _buildCategoryButtons(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 0; // Select Lab Tests
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == 0 ? theme.colorScheme.primary : theme.colorScheme.surface,
                foregroundColor: _selectedCategory == 0 ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: theme.colorScheme.primary), // Add border
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Lab Tests'),
            ),
          ),
          const SizedBox(width: 16), // Add spacing between buttons
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 1; // Select Radiology
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory == 1 ? theme.colorScheme.primary : theme.colorScheme.surface,
                foregroundColor: _selectedCategory == 1 ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: theme.colorScheme.primary), // Add border
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Radiology'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, ThemeData theme) {
    // Safely access data using correct column names from database
    final String title = report['Title'] ?? 'N/A';
    final String date = report['created_at'] != null
        ? DateFormat('dd MMM, yyyy').format(DateTime.parse(report['created_at']).toLocal())
        : 'N/A';
    final String status = report['status'] ?? 'N/A';
    // final String result = report['result'] ?? ''; // Assuming no separate result field, using status
    // Access doctor name from the nested object, providing default
    final String doctorName = report['doctors']?['name'] ?? 'N/A';

    // Determine status color based on status string
    Color statusColor = AppTheme.greyColor; // Default color
    if (status == 'Normal Results') {
      statusColor = Colors.green;
    } else if (status == 'Requires Attention') {
      statusColor = Colors.orange;
    } else if (status == 'Urgent') {
      statusColor = Colors.red;
    }

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
                child: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
              ),
              Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withAlpha(153)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(date, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(153))),
              // Removed result display as per assumption
              const Text(' . '), // Keep separator
                Text(
                status,
                style: theme.textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w500),
                ),
            ],
          ),
          // Removed description display as per assumption
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement View Report functionality
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LabRadiologyReportDetailsScreen(
                          reportData: report, // Pass the entire report map
                        ),
                      ),
                    );
                  },
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
                  onPressed: () => _pickAndUploadImage(report),
                  icon: Icon(Icons.upload, color: theme.colorScheme.primary),
                  label: Text('Upload', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
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
          Icon(Icons.receipt_long_outlined, size: 60, color: theme.colorScheme.onSurface.withOpacity(0.5)), // Changed icon
          const SizedBox(height: 18),
          Text('No lab or radiology reports found', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))), // Updated text
          const SizedBox(height: 8),
          Text(
            'Reports will appear here once they are available.', // Updated text
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)), // Adjusted opacity
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 