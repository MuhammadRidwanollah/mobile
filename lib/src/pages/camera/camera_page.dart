import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/face_detection_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  File? _imageFile;
  Map<String, dynamic>? _faceData;
  bool _isProcessing = false;

  @override
  void dispose() {
    _faceDetectionService.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (!cameraStatus.isGranted || !storageStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and storage permissions are required')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    await _requestPermissions();

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _faceData = null;
          _isProcessing = true;
        });

        // Process the image for face detection
        final faceData = await _faceDetectionService.detectFaces(_imageFile!);

        setState(() {
          _faceData = faceData;
          _isProcessing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detected ${faceData['face_count']} face(s)')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _sendToBackend() {
    if (_faceData != null) {
      // Here you would send _faceData to your backend
      // For demo, just show a dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Face Data'),
          content: SingleChildScrollView(
            child: Text(_faceData.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
        actions: [
          if (_faceData != null)
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendToBackend,
              tooltip: 'Send to Backend',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _takePhoto,
              icon: const Icon(Icons.camera),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const CircularProgressIndicator()
            else if (_imageFile != null)
              Expanded(
                child: Column(
                  children: [
                    Image.file(
                      _imageFile!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    if (_faceData != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Faces Detected: ${_faceData!['face_count']}'),
                              const SizedBox(height: 10),
                              Text(
                                'Face Data:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _faceData.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('No image selected'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}