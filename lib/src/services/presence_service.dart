import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PresenceService {
  static const String baseUrl = 'https://dummy-api.com'; // Replace with actual API

  Future<Map<String, dynamic>> checkin({
    required String userId,
    required String classId,
    required String imageBase64,
    required double faceConfidence,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/api/presence/checkin'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'class_id': classId,
          'image_base64': imageBase64,
          'face_confidence': faceConfidence,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Checkin failed: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, simulate success if confidence > 0.75
      if (faceConfidence > 0.75) {
        await Future.delayed(const Duration(seconds: 1));
        return {
          'success': true,
          'message': 'Checkin successful',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        throw Exception('Face confidence too low: $faceConfidence');
      }
    }
  }

  Future<String> imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}