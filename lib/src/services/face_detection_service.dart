import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<Map<String, dynamic>> detectFaces(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      List<Map<String, dynamic>> faceData = [];

      for (final face in faces) {
        final boundingBox = face.boundingBox;
        final landmarks = _extractLandmarks(face.landmarks);
        final smilingProbability = face.smilingProbability;
        final headEulerAngleX = face.headEulerAngleX;
        final headEulerAngleY = face.headEulerAngleY;
        final headEulerAngleZ = face.headEulerAngleZ;

        // Using smilingProbability as confidence for now, or calculate a custom confidence
        final confidence = smilingProbability ?? 0.0;

        faceData.add({
          'bounding_box': {
            'left': boundingBox.left,
            'top': boundingBox.top,
            'width': boundingBox.width,
            'height': boundingBox.height,
          },
          'landmarks': landmarks,
          'smiling_probability': smilingProbability,
          'head_euler_angles': {
            'x': headEulerAngleX,
            'y': headEulerAngleY,
            'z': headEulerAngleZ,
          },
          'confidence': confidence,
        });
      }

      return {
        'success': true,
        'faces': faceData,
        'face_count': faces.length,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'faces': [],
        'face_count': 0,
      };
    }
  }

  List<Map<String, dynamic>> _extractLandmarks(Map<FaceLandmarkType, FaceLandmark?> landmarks) {
    List<Map<String, dynamic>> landmarkList = [];

    landmarks.forEach((type, landmark) {
      if (landmark != null) {
        landmarkList.add({
          'type': type.name,
          'x': landmark.position.x,
          'y': landmark.position.y,
        });
      }
    });

    return landmarkList;
  }

  void dispose() {
    _faceDetector.close();
  }
}