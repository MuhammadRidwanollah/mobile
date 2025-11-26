import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class DashboardProvider with ChangeNotifier {
  UserModel? _userProfile;
  Map<String, dynamic>? _presenceSummary;
  bool _isLoading = false;
  String? _error;

  UserModel? get userProfile => _userProfile;
  Map<String, dynamic>? get presenceSummary => _presenceSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get monthlyAttendance => _presenceSummary?['monthly_attendance'] ?? 0;
  int get totalClasses => _presenceSummary?['total_classes'] ?? 0;

  static const String baseUrl = 'https://dummy-api.com'; // Replace with actual API

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchUserProfile(),
        _fetchPresenceSummary(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userProfile = UserModel.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, create dummy profile
      _userProfile = UserModel(
        id: 'user123',
        name: 'John Doe',
        email: 'john.doe@example.com',
        photoUrl: null,
        role: 'student',
      );
    }
  }

  Future<void> _fetchPresenceSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/presence/summary'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _presenceSummary = jsonDecode(response.body);
      } else {
        throw Exception('Failed to load summary: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, create dummy summary
      _presenceSummary = {
        'monthly_attendance': 15,
        'total_classes': 3,
        'total_sessions': 20,
      };
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}