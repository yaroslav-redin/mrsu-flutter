import 'package:flutter/material.dart';

// Rename this file to env.dart and fill in the values

class AppColors {
  static const Color primaryBlue = Color(0xFF007BFF);
  static const Color primaryPurple = Color(0xFF7C4DFF);
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryOrange = Color(0xFFFF6D00);
  
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceDark = Color(0xFF16213E);
}

class ApiConstants {
  static const String baseUrl = 'https://p.mrsu.ru';
  static const String papiUrl = 'https://papi.mrsu.ru/v1';
  static const String tokenEndpoint = '/OAuth/Token';
  
  // Auth
  static const String clientId = 'YOUR_CLIENT_ID';
  static const String clientSecret = 'YOUR_CLIENT_SECRET';
  
  // Endpoints
  static const String userEndpoint = 'User';
  static const String scheduleEndpoint = 'StudentTimeTable';
  static const String semesterEndpoint = 'StudentSemester';
  static const String ratingPlanEndpoint = 'StudentRatingPlan';
}

class StorageKeys {
  static const String accessToken = 'access_token';
  static const String isDarkTheme = 'isDark';
  static const String colorThemeName = 'colorThemeName';
}
