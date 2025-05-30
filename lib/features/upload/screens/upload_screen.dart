// lib/upload_screen.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

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
      _pageController.animateToPage(
        4,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e, st) {
      print('OCR failed: $e\n$st');
      setState(() => _busy = false);
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
        onTap: () {
          setState(() {
            _imageFile = null;
            _ocrText = '';
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
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildTile('Prescriptions', Icons.medical_services),
                        _buildTile('Lab reports', Icons.science),
                        _buildTile('Medication', Icons.local_pharmacy),
                        _buildTile('X-Ray', Icons.medical_information),
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
                CameraPreview(_camCtrl!),
                Center(child: _frameOverlay()),
                if (_busy)
                  Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
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
            // Page 4: OCR result
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Result OCR', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Expanded(child: SingleChildScrollView(child: Text(_ocrText, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _ocrText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Copied', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary)), backgroundColor: theme.colorScheme.primary),
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
