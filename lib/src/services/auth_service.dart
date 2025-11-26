import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://dummy-api.com'; // Replace with actual API

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return data;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, simulate success
      await Future.delayed(const Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'dummy_token_${DateTime.now().millisecondsSinceEpoch}');
      return {'token': 'dummy_token', 'user': {'id': '1', 'name': 'Test User'}};
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return data;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, simulate success
      await Future.delayed(const Duration(seconds: 1));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'dummy_token_${DateTime.now().millisecondsSinceEpoch}');
      return {'token': 'dummy_token', 'user': {'id': '1', 'name': name}};
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}