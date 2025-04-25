import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:medease/Camera/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import"package:flutter/material.dart";

void main() {
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Camera App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CameraScreen(), // this is where you show your screen
    );
  }
}


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {

  final _textRecogniser = TextRecognizer();
  bool _isPermissionGranted = false;
  CameraController? _cameraController;
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = _requestCameraPermission(); // Make sure _requestCameraPermission() returns a Future
  }

  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    _textRecogniser.close();
    super.dispose();
  }

  void didChangelifeCylce(AppLifecycleState state){
    if (_cameraController != null || !_cameraController!.value.isInitialized){
      return;
    }
    if (state == AppLifecycleState.inactive){
      _stopCamera();
    } else if (state == AppLifecycleState.resumed && _cameraController != null && _cameraController!.value.isInitialized){
      _startCamera();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isPermissionGranted = status == PermissionStatus.granted;
    });
  }

  void _startCamera(){
    if (_cameraController != null){
      _cameraSelected(_cameraController!.description);
    }
  }
  void _stopCamera(){
    if (_cameraController != null){
      _cameraController?.dispose();
    }
  }

  void _initCamera(List<CameraDescription> cameras){
    if (_cameraController != null){
      return;
    }
    CameraDescription? camera;
    for (var i = 0; i<cameras.length; i++){
      final CameraDescription current = cameras[i];
      camera = current;
      break;
    }
    if (camera != null){
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async{
    _cameraController = CameraController(camera, ResolutionPreset.max, enableAudio: false);
    await _cameraController?.initialize();
    if(!mounted){
      return;
    }
    setState(() {});
  }

Future<void> _scanImage() async {
  if(_cameraController == null) return;
  final navigator = Navigator.of(context);
  try{
    final pictureFile = await _cameraController!.takePicture();
    final file = File(pictureFile.path);
    final inputImage = InputImage.fromFile(file);
    final recognizedText = await _textRecogniser.processImage(inputImage);
    await navigator.push(MaterialPageRoute(builder: (context) => ResultScreen(text: recognizedText.text)));
  }catch (e){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Errrrrorrrrrr")));
  }
}
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          print(_isPermissionGranted
              ? "Camera Permission Granted"
              : "Camera Permission Denied");

          return Stack(
            children: [
              if (_isPermissionGranted)
                FutureBuilder<List<CameraDescription>>(
                  future: availableCameras(),
                  builder: (context, cameraSnapshot) {
                    if (cameraSnapshot.connectionState == ConnectionState.done &&
                        cameraSnapshot.hasData) {
                      _initCamera(cameraSnapshot.data!);
                      return _cameraController != null &&
                          _cameraController!.value.isInitialized
                          ? CameraPreview(_cameraController!)
                          : const Center(child: CircularProgressIndicator());
                    } else {
                      return const LinearProgressIndicator();
                    }
                  },
                ),
              Scaffold(
                appBar: AppBar(
                  title: const Text("Text Recognition"), // fixed typo
                ),
                backgroundColor:
                _isPermissionGranted ? Colors.transparent : null,
                body: _isPermissionGranted
                    ? Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: ElevatedButton(
                        onPressed: _scanImage,
                        child: const Text("Scan here"),
                      ),
                    ),
                  ],
                )
                    : const Center(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Camera Denied",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }}
