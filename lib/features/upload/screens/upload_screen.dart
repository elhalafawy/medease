// lib/upload_screen.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import provider
import 'ocr_result.dart'; // Import the OCR result screen
import '../models/analysis_result.dart'; // Import the analysis result model
import 'analysis_result_screen.dart'; // Import the analysis result screen
import '../../../core/providers/analysis_result_provider.dart'; // Import the analysis result provider
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  CameraController? _camCtrl;
  XFile? _imageFile;
  String _ocrText = '';
  bool _busy = false;
  bool _flashOn = false;

  List<Map<String, dynamic>> _labReportsWithoutImage = [];
  Map<String, dynamic>? _selectedLabReport;

  List<Map<String, dynamic>> _radiologyReportsWithoutImage = [];
  Map<String, dynamic>? _selectedRadiologyReport;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initCamera();
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

  Future<void> _fetchLabReportsWithoutImage() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      // Get patient_id for this user
      final patient = await Supabase.instance.client
          .from('patients')
          .select('patient_id')
          .eq('user_id', user.id)
          .maybeSingle();
      if (patient == null) return;
      final patientId = patient['patient_id'];
      final response = await Supabase.instance.client
          .from('lab_reports')
          .select('*')
          .eq('patient_id', patientId)
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
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      // Get patient_id for this user
      final patient = await Supabase.instance.client
          .from('patients')
          .select('patient_id')
          .eq('user_id', user.id)
          .maybeSingle();
      if (patient == null) return;
      final patientId = patient['patient_id'];
      final response = await Supabase.instance.client
          .from('Radiology')
          .select('*')
          .eq('patient_id', patientId)
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
                    _flashOn = false;
                    if (_camCtrl != null) {
                      _camCtrl!.setFlashMode(FlashMode.off);
                    }
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
                    _flashOn = false;
                    if (_camCtrl != null) {
                      _camCtrl!.setFlashMode(FlashMode.off);
                    }
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

      if (_selectedLabReport != null) {
        // --- Upload image to Supabase Storage and update lab report ---
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        final patient = await Supabase.instance.client
            .from('patients')
            .select('patient_id')
            .eq('user_id', user.id)
            .maybeSingle();
        if (patient == null) return;
        final patientId = patient['patient_id'];
        final reportId = _selectedLabReport!['report_id'].toString();
        final fileExt = img.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '$patientId/$fileName';
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
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;
        final patient = await Supabase.instance.client
            .from('patients')
            .select('patient_id')
            .eq('user_id', user.id)
            .maybeSingle();
        if (patient == null) return;
        final patientId = patient['patient_id'];
        final reportId = _selectedRadiologyReport!['Radiology_id'].toString();
        final fileExt = img.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '$patientId/$fileName';
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
      }

      // Default OCR flow for other tiles
      _pageController.animateToPage(
        4, // Index of the OCR result page
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _flashOn = false;
      if (_camCtrl != null) {
        _camCtrl!.setFlashMode(FlashMode.off);
      }
    } catch (e, st) {
      print('OCR failed: $e\n$st');
      setState(() => _busy = false);
    }
  }

  Future<void> _analyzeText(BuildContext context) async {
    if (_ocrText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to analyze'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('Starting text analysis...');
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Analyzing text...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      print('Text to analyze: $_ocrText');
      
      // Perform analysis
      final result = await AnalysisResult.fromText(_ocrText);
      print('Analysis completed: ${result.diagnosis}');

      // Set the result in the provider
      Provider.of<AnalysisResultProvider>(context, listen: false).setAnalysisResult(result);

      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show results
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(result: result),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error during analysis: $e');
      print('Stack trace: $stackTrace');
      
      // Hide loading indicator
      if (context.mounted) {
        Navigator.pop(context);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing text: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
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

  Widget _buildDots() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _pageIndex == i ? 12 : 8,
          height: _pageIndex == i ? 12 : 8,
          decoration: BoxDecoration(
            color: _pageIndex == i ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(80),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _frameOverlay() {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.onPrimary, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTile(String label, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () async {
          if (label == 'Lab reports') {
            await _showLabReportSelectionDialog();
            return;
          }
          setState(() {
            _imageFile = null;
            _ocrText = '';
            _flashOn = false;
            if (_camCtrl != null) {
              _camCtrl!.setFlashMode(FlashMode.off);
            }
          });
          _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildTileWithImage(String label, String assetPath) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: () async {
          if (label == 'Radiology') {
            await _showRadiologyReportSelectionDialog();
            return;
          }
          setState(() {
            _imageFile = null;
            _ocrText = '';
            _flashOn = false;
            if (_camCtrl != null) {
              _camCtrl!.setFlashMode(FlashMode.off);
            }
          });
          _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(assetPath, width: 48, height: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final camReady = _camCtrl != null && _camCtrl!.value.isInitialized;

    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Flow', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(children: [
        PageView(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _pageIndex = i),
          children: [
            // Page 0: Home grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Upload Documents', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
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
                                child: _buildTile('Prescriptions', Icons.medical_services),
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
                                child: _buildTile('Lab reports', Icons.science),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 160,
                                child: _buildTileWithImage('Radiology', 'assets/icons/Radiology.png'),
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
            // Page 1: Live camera
            if (!camReady)
              const Center(child: CircularProgressIndicator())
            else
            Stack(
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  child: CameraPreview(_camCtrl!),
                ),
                Center(child: _frameOverlay()),
                if (_busy)
                  Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
                // Flash icon above the camera button
                Positioned(
                  bottom: 100, // Adjust as needed to be above the camera button
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, size: 32, color: _flashOn ? Colors.amber : theme.colorScheme.primary),
                      onPressed: () async {
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                        if (_camCtrl != null) {
                          await _camCtrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24, left: 24, right: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo, size: 32, color: theme.colorScheme.primary),
                        onPressed: () async {
                          final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (img != null) await _doOCR(img);
                        },
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          try {
                            if (_camCtrl != null) {
                              await _camCtrl!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
                            }
                            final pic = await _camCtrl!.takePicture();
                            await _doOCR(pic);
                          } catch (e) {
                            print('Capture failed: $e');
                          }
                        },
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.camera_alt, size: 32, color: theme.colorScheme.onPrimary),
                      ),
                      IconButton(
                        icon: Icon(Icons.insert_drive_file, size: 32, color: theme.colorScheme.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Page 2: Original image
            _imageFile == null
              ? Center(child: Text('No image yet', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)))
              : Image.file(File(_imageFile!.path), fit: BoxFit.contain),
            // Page 3: Crop overlay
            _imageFile == null ? const SizedBox() : Stack(
              children: [
                Image.file(File(_imageFile!.path), fit: BoxFit.contain),
                Center(child: Opacity(opacity: .4, child: _frameOverlay())),
              ],
            ),
            // Page 4: OCR result and Analysis Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Result OCR', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _ocrText,
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Analyze Text Button
                  ElevatedButton.icon(
                    onPressed: () => _analyzeText(context),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Analyze Text'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16), // Add some spacing
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _ocrText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)), backgroundColor: theme.colorScheme.primary), // Corrected snackbar
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.share, color: theme.colorScheme.primary),
                        onPressed: () {
                          if (_ocrText.isNotEmpty) Share.share(_ocrText);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: _buildDots(),
        ),
      ]),
    );
  }
}
