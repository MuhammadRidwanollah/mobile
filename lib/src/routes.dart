import 'package:flutter/material.dart';
import 'pages/auth/auth_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/presence/presence_page.dart';
import 'pages/profile/profile_page.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const AuthPage(),
  '/dashboard': (context) => const DashboardPage(),
  '/presence': (context) => const PresencePage(),
  '/profile': (context) => const ProfilePage(),
};