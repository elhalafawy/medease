import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:cached_network_image/cached_network_image.dart'; // Import for caching network images
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LabRadiologyReportDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const LabRadiologyReportDetailsScreen({super.key, required this.reportData});

  @override
  State<LabRadiologyReportDetailsScreen> createState() => _LabRadiologyReportDetailsScreenState();
}

class _LabRadiologyReportDetailsScreenState extends State<LabRadiologyReportDetailsScreen> {
  SupabaseClient get _supabase => Supabase.instance.client;
  String? _publicUrl;
  List<Map<String, dynamic>> _medicalRecords = [];
  bool _isLoadingMedicalRecords = true;
  String? selectedMedicalRecordId;

  @override
  void initState() {
    super.initState();
    _generatePublicUrl();
    _loadMedicalRecords();
  }

  Future<void> _generatePublicUrl() async {
    final String? reportUrl = widget.reportData['report_url'];
    if (reportUrl == null) return;

    try {
      // Determine if this is a lab report or radiology report
      final bool isLabReport = widget.reportData.containsKey('report_id');
      final String bucket = isLabReport ? 'labreports' : 'radiology';

      print('=== URL Generation Debug ===');
      print('File path: $reportUrl');
      print('Bucket: $bucket');
      
      // Get the public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(reportUrl);
      print('Generated URL: $url');
      
      if (mounted) {
        setState(() {
          _publicUrl = url;
        });
      }
    } catch (e) {
      print('Error generating public URL: $e');
    }
  }

  Future<void> _openFile(String? url) async {
    if (url == null) {
      print('Cannot open file: URL is null');
      return;
    }
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error opening file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: ${e.toString()}')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMedicalRecords() async {
    final records = await _supabase
        .from('medical_records')
        .select('record_id, record_number, created_at')
        .eq('patient_id', widget.reportData['patient_id'])
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(records);
  }

  Future<void> _loadMedicalRecords() async {
    try {
      setState(() {
        _isLoadingMedicalRecords = true;
      });
      final response = await _supabase
          .from('medical_records')
          .select('record_id, record_number, created_at')
          .eq('patient_id', widget.reportData['patient_id'])
          .order('created_at', ascending: false);
      setState(() {
        _medicalRecords = List<Map<String, dynamic>>.from(response);
        _isLoadingMedicalRecords = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMedicalRecords = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String? reportUrl = widget.reportData['report_url'];

    print('=== Report Details Debug ===');
    print('Report URL from database: $reportUrl');
    print('Generated public URL: $_publicUrl');

    // Safely access data from the reportData map
    final String title = widget.reportData['Title'] ?? 'N/A';
    final String date = widget.reportData['created_at'] != null
        ? DateFormat('dd MMM, yyyy').format(DateTime.parse(widget.reportData['created_at']).toLocal())
        : 'N/A';
    final String status = widget.reportData['status'] ?? 'N/A';
    final String doctorName = widget.reportData['doctors']?['name'] ?? 'N/A';
    final String patientId = widget.reportData['patient_id']?.toString() ?? 'N/A';
    final String reportId = widget.reportData['report_id']?.toString() ?? widget.reportData['Radiology_id']?.toString() ?? 'N/A';

    // Debug: Print extracted data
    print('Extracted report details:');
    print('Title: $title');
    print('Date: $date');
    print('Status: $status');
    print('Doctor: $doctorName');
    print('Patient ID: $patientId');
    print('Report ID: $reportId');
    print('Report URL: $reportUrl');
    print('Public URL: $_publicUrl');

    // Function to determine if the URL is an image
    bool isImageUrl(String? url) {
      if (url == null) return false;
      final lowercaseUrl = url.toLowerCase();
      return lowercaseUrl.endsWith('.jpg') || 
             lowercaseUrl.endsWith('.jpeg') || 
             lowercaseUrl.endsWith('.png') || 
             lowercaseUrl.endsWith('.gif') ||
             lowercaseUrl.endsWith('.webp');
    }

    // Function to determine if the URL is a PDF
    bool isPdfUrl(String? url) {
      if (url == null) return false;
      return url.toLowerCase().endsWith('.pdf');
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
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
              valueColor: _getStatusColor(status, theme),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Added by Doctor',
              value: doctorName,
              icon: Icons.person_outline,
              theme: theme,
            ),
            const SizedBox(height: 16),
            Card(
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _publicUrl == null ? Icons.upload_file : 
                          isPdfUrl(reportUrl) ? Icons.picture_as_pdf :
                          isImageUrl(reportUrl) ? Icons.image : 
                          Icons.file_present,
                          color: theme.colorScheme.primary
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Report File',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_publicUrl == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.no_photography,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No report file uploaded yet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isImageUrl(reportUrl))
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: _publicUrl!,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: theme.colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                print('Error loading image: $error');
                                print('Attempted URL: $url');
                                return Container(
                                  height: 200,
                                  color: theme.colorScheme.surface,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: theme.colorScheme.error,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Error loading image',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Colors.black,
                                          leading: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white),
                                            onPressed: () => Navigator.pop(context),
                                          ),
                                        ),
                                        body: Container(
                                          color: Colors.black,
                                          child: Center(
                                            child: InteractiveViewer(
                                              minScale: 0.5,
                                              maxScale: 4.0,
                                              child: CachedNetworkImage(
                                                imageUrl: _publicUrl!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.fullscreen, color: theme.colorScheme.primary),
                                label: Text(
                                  'View Full Screen',
                                  style: TextStyle(color: theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (isPdfUrl(reportUrl))
                      ElevatedButton.icon(
                        onPressed: () => _openFile(_publicUrl),
                        icon: Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
                        label: Text('Open PDF', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _openFile(_publicUrl),
                        icon: Icon(Icons.open_in_new, color: theme.colorScheme.primary),
                        label: Text('Open File', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
        return theme.colorScheme.onSurface.withOpacity(0.7);
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
              style: theme.textTheme.bodyLarge?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 