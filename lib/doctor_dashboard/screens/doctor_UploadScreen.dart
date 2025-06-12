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
  bool _flashOn = false;

  List<Map<String, dynamic>> _patients = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  String? _selectedPatientDOB;
  bool _isLoadingPatients = true;
  List<Map<String, dynamic>> _labReportsWithoutImage = [];
  Map<String, dynamic>? _selectedLabReport;
  List<Map<String, dynamic>> _radiologyReportsWithoutImage = [];
  Map<String, dynamic>? _selectedRadiologyReport;

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
    // Always turn off flash before navigating
    setState(() {
      _flashOn = false;
    });
    if (_camCtrl != null) {
      _camCtrl!.setFlashMode(FlashMode.off);
    }
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
      final input = InputImage.fromFilePath(img.path);
      final rec = TextRecognizer();
      final res = await rec.processImage(input);
      await rec.close();
      setState(() {
        _imageFile = img;
        _ocrText = res.text;
        _busy = false;
      });

      final analysis = await AnalysisResult.fromText(_ocrText);
      if (_selectedPatientId != null) {
        if (_selectedLabReport != null) {
          // --- Upload image to Supabase Storage and update lab report ---
          final reportId = _selectedLabReport!['report_id'].toString();
          final fileExt = img.path.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = '$_selectedPatientId/$fileName';
          final bytes = await img.readAsBytes();
          final supabase = Supabase.instance.client;
          await supabase.storage.from('labreports').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );
          await supabase
              .from('lab_reports')
              .update({'report_url': filePath})
              .eq('report_id', reportId);
          setState(() {
            _selectedLabReport = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lab report image uploaded and saved!')),
          );
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return;
        } else if (_selectedRadiologyReport != null) {
          // --- Upload image to Supabase Storage and update radiology report ---
          final reportId = _selectedRadiologyReport!['Radiology_id'].toString();
          final fileExt = img.path.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final filePath = '$_selectedPatientId/$fileName';
          final bytes = await img.readAsBytes();
          final supabase = Supabase.instance.client;
          await supabase.storage.from('radiology').uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );
          await supabase
              .from('Radiology')
              .update({'report_url': filePath})
              .eq('Radiology_id', reportId);
          setState(() {
            _selectedRadiologyReport = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Radiology image uploaded and saved!')),
          );
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return;
        } else {
          _showOcrResultScreen(context, analysis);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a patient first')),
        );
      }
    } catch (e, st) {
      print('OCR failed: $e\n$st');
      setState(() => _busy = false);
    }
  }

  Future<void> _fetchLabReportsWithoutImage() async {
    if (_selectedPatientId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('lab_reports')
          .select('*')
          .eq('patient_id', _selectedPatientId!)
          .or('report_url.is.null,report_url.eq.""');
      setState(() {
        _labReportsWithoutImage = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching lab reports without image: $e');
      setState(() {
        _labReportsWithoutImage = [];
      });
    }
  }

  Future<void> _fetchRadiologyReportsWithoutImage() async {
    if (_selectedPatientId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('Radiology')
          .select('*')
          .eq('patient_id', _selectedPatientId!)
          .or('report_url.is.null,report_url.eq.""');
      setState(() {
        _radiologyReportsWithoutImage = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching radiology reports without image: $e');
      setState(() {
        _radiologyReportsWithoutImage = [];
      });
    }
  }

  Future<void> _showLabReportSelectionDialog() async {
    await _fetchLabReportsWithoutImage();
    if (_labReportsWithoutImage.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Lab Reports'),
          content: const Text('No lab reports available for upload.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Lab Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _labReportsWithoutImage.length,
            itemBuilder: (context, index) {
              final report = _labReportsWithoutImage[index];
              return ListTile(
                title: Text(report['Title'] ?? 'Untitled'),
                subtitle: Text(report['created_at']?.toString() ?? ''),
                onTap: () {
                  setState(() {
                    _selectedLabReport = report;
                  });
                  Navigator.pop(context);
                  // Proceed to OCR flow (camera page)
                  setState(() {
                    _imageFile = null;
                    _ocrText = '';
                  });
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showRadiologyReportSelectionDialog() async {
    await _fetchRadiologyReportsWithoutImage();
    if (_radiologyReportsWithoutImage.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Radiology Reports'),
          content: const Text('No radiology reports available for upload.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Radiology Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _radiologyReportsWithoutImage.length,
            itemBuilder: (context, index) {
              final report = _radiologyReportsWithoutImage[index];
              return ListTile(
                title: Text(report['Title'] ?? 'Untitled'),
                subtitle: Text(report['created_at']?.toString() ?? ''),
                onTap: () {
                  setState(() {
                    _selectedRadiologyReport = report;
                  });
                  Navigator.pop(context);
                  // Proceed to OCR flow (camera page)
                  setState(() {
                    _imageFile = null;
                    _ocrText = '';
                  });
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
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

  Widget _buildTile(BuildContext context, String label, IconData icon) {
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
          if (label == 'Lab reports') {
            await _showLabReportSelectionDialog();
            return;
          }
          // Navigate to camera page for scanning
          setState(() {
            _imageFile = null;
            _ocrText = '';
          });
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
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

  Widget _buildTileWithImage(BuildContext context, String label, String assetPath) {
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
          if (label == 'Radiology') {
            await _showRadiologyReportSelectionDialog();
            return;
          }
          setState(() {
            _imageFile = null;
            _ocrText = '';
          });
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 48, height: 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.white)),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // First row: Prescriptions centered
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 160,
                                  child: _buildTile(
                                    context,
                                    'Prescriptions',
                                    Icons.medical_services,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Second row: Lab reports and Radiology side by side
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 160,
                                  child: _buildTile(
                                    context,
                                    'Lab reports',
                                    Icons.science,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 160,
                                  child: _buildTileWithImage(
                                    context,
                                    'Radiology',
                                    'assets/icons/Radiology.png',
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                    // Make camera preview fill the whole screen
                    Positioned.fill(
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        child: CameraPreview(_camCtrl!),
                      ),
                    ),
                    Center(child: _frameOverlay()),
                    if (_busy)
                      Container(
                          color: Colors.black26,
                          child:
                              const Center(child: CircularProgressIndicator())),
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _flashOn ? Icons.flash_on : Icons.flash_off,
                            size: 32,
                            color: _flashOn ? Colors.amber : Colors.white,
                          ),
                          onPressed: () async {
                            setState(() {
                              _flashOn = !_flashOn;
                            });
                            if (_camCtrl != null) {
                              await _camCtrl!.setFlashMode(
                                _flashOn ? FlashMode.torch : FlashMode.off,
                              );
                            }
                          },
                        ),
                      ),
                    ),
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
                                if (_camCtrl != null) {
                                  await _camCtrl!.setFlashMode(
                                    _flashOn ? FlashMode.torch : FlashMode.off,
                                  );
                                }
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
