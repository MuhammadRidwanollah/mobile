import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/face_detection_service.dart';
import '../../services/presence_service.dart';

class PresencePage extends StatefulWidget {
  const PresencePage({super.key});

  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  final ImagePicker _picker = ImagePicker();
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final PresenceService _presenceService = PresenceService();

  File? _imageFile;
  Map<String, dynamic>? _faceData;
  bool _isProcessing = false;
  double? _faceConfidence;

  // Dummy data - in real app, get from user selection or API
  final String userId = 'user123';
  final String classId = 'class456';

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

  Future<void> _ambilFoto() async {
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
          _faceConfidence = null;
          _isProcessing = true;
        });

        // Process the image for face detection
        final faceData = await _faceDetectionService.detectFaces(_imageFile!);

        setState(() {
          _faceData = faceData;
          _isProcessing = false;
        });

        // Get confidence from first face (if any)
        if (faceData['success'] == true && faceData['faces'].isNotEmpty) {
          final firstFace = faceData['faces'][0] as Map<String, dynamic>;
          _faceConfidence = firstFace['confidence'] as double?;
          setState(() {});

          // Auto-submit if confidence is good
          if (_faceConfidence != null && _faceConfidence! > 0.75) {
            await _submitCheckin();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Face confidence too low: ${_faceConfidence?.toStringAsFixed(2) ?? 'N/A'}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No face detected'),
                backgroundColor: Colors.red,
              ),
            );
          }
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

  Future<void> _submitCheckin() async {
    if (_imageFile == null || _faceConfidence == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final imageBase64 = await _presenceService.imageToBase64(_imageFile!);
      final result = await _presenceService.checkin(
        userId: userId,
        classId: classId,
        imageBase64: imageBase64,
        faceConfidence: _faceConfidence!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Absensi berhasil! ${result['message'] ?? ''}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Reset state
      setState(() {
        _imageFile = null;
        _faceData = null;
        _faceConfidence = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Absensi gagal: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Presence'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Ambil Foto Wajah',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _ambilFoto,
                      icon: const Icon(Icons.camera),
                      label: const Text('Ambil Foto'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isProcessing)
              const CircularProgressIndicator()
            else if (_imageFile != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Foto Terambil',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        if (_faceConfidence != null)
                          Column(
                            children: [
                              Text(
                                'Face Confidence: ${_faceConfidence!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _faceConfidence! > 0.75 ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_faceConfidence! > 0.75)
                                const Text(
                                  '✅ Siap untuk check-in',
                                  style: TextStyle(color: Colors.green),
                                )
                              else
                                const Text(
                                  '❌ Confidence terlalu rendah',
                                  style: TextStyle(color: Colors.red),
                                ),
                            ],
                          ),
                        if (_faceData != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Faces detected: ${_faceData!['face_count']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'Tekan tombol "Ambil Foto" untuk memulai absensi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}