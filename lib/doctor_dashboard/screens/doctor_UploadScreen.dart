import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'patient_medical_record_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/upload/models/analysis_result.dart';
import 'doctor_ocr_result_screen.dart';
import 'lab_radiology_report_details_screen.dart';

class DoctorUploadscreen extends StatefulWidget {
  const DoctorUploadscreen({super.key});

  @override
  State<DoctorUploadscreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<DoctorUploadscreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  CameraController? _camCtrl;
  XFile? _imageFile;
  String _ocrText = '';
  bool _busy = false;

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedPatientDOB;
  bool _isLoadingPatients = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initCamera();
    _loadPatients();
  }

  Future<void> _initCamera() async {
    try {
      if (!await Permission.camera.request().isGranted) {
        print('Camera permission denied');
        return;
      }
      final cams = await availableCameras();
      _camCtrl = CameraController(cams.first, ResolutionPreset.high);
      await _camCtrl!.initialize();
      if (mounted) setState(() {});
    } catch (e, st) {
      print('Camera init failed: $e\n$st');
    }
  }

  Future<void> _loadPatients() async {
    try {
      setState(() => _isLoadingPatients = true);
      final response = await Supabase.instance.client
          .from('patients')
          .select('patient_id, full_name, date_of_birth')
          .order('full_name');
      setState(() {
        _patients = List<Map<String, dynamic>>.from(response);
        _isLoadingPatients = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() => _isLoadingPatients = false);
    }
  }

  void _showOcrResultScreen(BuildContext context, AnalysisResult analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorOcrResultScreen(
          analysis: analysis,
          patientId: _selectedPatientId!,
          patientName: _selectedPatientName ?? '',
          patientDOB: _selectedPatientDOB ?? 'Unknown',
        ),
      ),
    );
  }

  Future<void> _doOCR(XFile img) async {
    try {
      setState(() => _busy = true);

      // Get current user (doctor)
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get doctor ID
      final doctorResponse = await Supabase.instance.client
          .from('doctors')
          .select('doctor_id')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (doctorResponse == null) {
        throw Exception('Doctor profile not found');
      }

      final doctorId = doctorResponse['doctor_id'];

      // Upload image to Supabase Storage
      final bytes = await img.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = _pageIndex == 1 ? 'lab_reports' : 'radiology';

      // Create a temporary file
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Upload the file
      await Supabase.instance.client.storage
          .from(storagePath)
          .upload(fileName, tempFile);

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
          .from(storagePath)
          .getPublicUrl(fileName);

      // Save record to database
      final tableName = _pageIndex == 1 ? 'lab_reports' : 'Radiology';
      final record = {
        'patient_id': _selectedPatientId,
        'doctor_id': doctorId,
        'Title':
            '${_pageIndex == 1 ? "Lab Report" : "Radiology"} - ${DateTime.now().toString().split('.')[0]}',
        'status': 'pending',
        'report_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from(tableName).insert(record);

      setState(() {
        _imageFile = img;
        _busy = false;
      });

      if (mounted) {
        // Navigate to the details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LabRadiologyReportDetailsScreen(
              reportData: {
                'Title':
                    '${_pageIndex == 1 ? "Lab Report" : "Radiology"} - ${DateTime.now().toString().split('.')[0]}',
                'created_at': DateTime.now().toIso8601String(),
                'status': 'pending',
                'report_url': imageUrl,
                'patient_id': _selectedPatientId,
                'doctors': {'name': 'Current Doctor'},
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error handling image: $e');
      setState(() => _busy = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageOptions(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    await _handleImageSelection(image, type);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    await _handleImageSelection(image, type);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: const Text('Choose File'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    await _handleImageSelection(image, type);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleImageSelection(XFile image, String type) async {
    try {
      setState(() => _busy = true);

      // Get current user (doctor)
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get doctor ID
      final doctorResponse = await Supabase.instance.client
          .from('doctors')
          .select('doctor_id')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (doctorResponse == null) {
        throw Exception('Doctor profile not found');
      }

      final doctorId = doctorResponse['doctor_id'];

      // Upload image to Supabase Storage
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = type == 'Lab Reports' ? 'lab_reports' : 'radiology';

      // Create a temporary file
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      // Upload the file
      await Supabase.instance.client.storage
          .from(storagePath)
          .upload(fileName, tempFile);

      // Get the public URL of the uploaded image
      final imageUrl = Supabase.instance.client.storage
          .from(storagePath)
          .getPublicUrl(fileName);

      // Save record to database
      final tableName = type == 'Lab Reports' ? 'lab_reports' : 'Radiology';
      final record = {
        'patient_id': _selectedPatientId,
        'doctor_id': doctorId,
        'Title': '${type} Report - ${DateTime.now().toString().split('.')[0]}',
        'status': 'pending',
        'report_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from(tableName).insert(record);

      setState(() {
        _imageFile = image;
        _busy = false;
      });

      if (mounted) {
        // Navigate to the details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LabRadiologyReportDetailsScreen(
              reportData: {
                'Title':
                    '${type} Report - ${DateTime.now().toString().split('.')[0]}',
                'created_at': DateTime.now().toIso8601String(),
                'status': 'pending',
                'report_url': imageUrl,
                'patient_id': _selectedPatientId,
                'doctors': {'name': 'Current Doctor'},
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error handling image: $e');
      setState(() => _busy = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  Widget _frameOverlay() {
    return Container(
      width: 250,
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTile(BuildContext context, String label, dynamic icon) {
    final theme = Theme.of(context);
    return Card(
      color: theme.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          if (_selectedPatientId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a patient first')),
            );
            return;
          }

          if (label == 'Lab reports' || label == 'Radiology') {
            // Navigate to camera page directly
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            _showImageOptions(context, label);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is IconData)
              Icon(icon, size: 48, color: Colors.white)
            else if (icon is String)
              Image.asset(
                icon,
                width: 48,
                height: 48,
                color: Colors.white,
              ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    theme.textTheme.bodyLarge!.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _pageIndex == i ? 12 : 8,
          height: _pageIndex == i ? 12 : 8,
          decoration: BoxDecoration(
            color: _pageIndex == i ? theme.primaryColor : theme.dividerColor,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final camReady = _camCtrl != null && _camCtrl!.value.isInitialized;

    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('OCR Flow', style: theme.appBarTheme.titleTextStyle),
          backgroundColor: AppTheme.appBarBackgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 1,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: Stack(children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _pageIndex = i),
            children: [
              // Page 0: Home Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_isLoadingPatients)
                      const CircularProgressIndicator()
                    else
                      DropdownButton<String>(
                        value: _selectedPatientId,
                        dropdownColor: theme.cardColor,
                        style: theme.textTheme.titleLarge,
                        hint: Text("Select Patient",
                            style: theme.textTheme.titleLarge),
                        iconEnabledColor: theme.primaryColor,
                        items: _patients.map((patient) {
                          return DropdownMenuItem<String>(
                            value: patient['patient_id'],
                            child: Text(patient['full_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final patient = _patients
                                .firstWhere((p) => p['patient_id'] == value);
                            setState(() {
                              _selectedPatientId = value;
                              _selectedPatientName = patient['full_name'];
                              _selectedPatientDOB =
                                  patient['date_of_birth']?.toString();
                            });
                          }
                        },
                      ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildTile(
                              context, 'Prescriptions', Icons.medical_services),
                          _buildTile(context, 'Lab reports', Icons.science),
                          _buildTile(
                              context, 'Medication', Icons.local_pharmacy),
                          _buildTile(context, 'Radiology',
                              'assets/icons/Radiology.png'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Page 1: Live Camera
              if (!camReady)
                const Center(child: CircularProgressIndicator())
              else
                Stack(
                  children: [
                    CameraPreview(_camCtrl!),
                    Center(child: _frameOverlay()),
                    if (_busy)
                      Container(
                          color: Colors.black26,
                          child:
                              const Center(child: CircularProgressIndicator())),
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo,
                                size: 32, color: Colors.white),
                            onPressed: () async {
                              final img = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (img != null) await _doOCR(img);
                            },
                          ),
                          FloatingActionButton(
                            onPressed: () async {
                              try {
                                final pic = await _camCtrl!.takePicture();
                                await _doOCR(pic);
                              } catch (e) {
                                print('Capture failed: $e');
                              }
                            },
                            backgroundColor: theme.primaryColor,
                            child: const Icon(Icons.camera_alt, size: 32),
                          ),
                          IconButton(
                            icon: const Icon(Icons.insert_drive_file,
                                size: 32, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              // Page 2: Original Image
              _imageFile == null
                  ? Center(
                      child: Text('No image yet',
                          style: theme.textTheme.bodyLarge))
                  : Image.file(File(_imageFile!.path), fit: BoxFit.contain),

              // Page 3: Crop Overlay
              _imageFile == null
                  ? const SizedBox()
                  : Stack(
                      children: [
                        Image.file(File(_imageFile!.path), fit: BoxFit.contain),
                        Center(
                            child:
                                Opacity(opacity: .4, child: _frameOverlay())),
                      ],
                    ),

              // Page 4: OCR Result
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Result OCR', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_ocrText, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _ocrText));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Copied')));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () => Share.share(_ocrText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(bottom: 16, left: 0, right: 0, child: _buildDots(context)),
        ]),
      ),
    );
  }
}
