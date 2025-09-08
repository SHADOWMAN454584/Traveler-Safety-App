import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Tourist Safety';
  static const String appTagline = 'Smart Safety for Smarter Tourism';

  // API Endpoints
  static const String baseUrl = 'https://api.touristsafety.com';
  static const String touristRegisterUrl = '/api/tourist/register';
  static const String touristByIdUrl = '/api/tourist';
  static const String panicAlertUrl = '/api/alerts/panic';
  static const String geofenceAlertUrl = '/api/alerts/geofence';
  static const String dashboardClustersUrl = '/api/dashboard/clusters';
  static const String dashboardEfirUrl = '/api/dashboard/efir';
  static const String anomalyCheckUrl = '/api/anomaly/check';
  static const String languageUrl = '/api/lang';

  // Emergency Contacts
  static const String policeNumber = '100';
  static const String ambulanceNumber = '108';
  static const String touristHelpline = '1363';

  // Language Codes
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ'},
    {'code': 'or', 'name': 'Odia', 'nativeName': 'ଓଡ଼ିଆ'},
  ];

  // Geofence Radius (in meters)
  static const double defaultGeofenceRadius = 1000.0;
  static const double highRiskGeofenceRadius = 500.0;

  // Safety Score Thresholds
  static const int highSafetyScore = 80;
  static const int mediumSafetyScore = 50;
  static const int lowSafetyScore = 30;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 16.0;
  static const double largeRadius = 24.0;
  static const double circularRadius = 50.0;
}

class AppColors {
  // Primary Gradient Colors
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color primaryPurple = Color(0xFF7C3AED);

  // Secondary Colors
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color lightPurple = Color(0xFF8B5CF6);

  // Accent Colors
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentPurple = Color(0xFFA78BFA);

  // Status Colors
  static const Color safeGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color panicRed = Color(0xFFDC2626);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF374151);
  static const Color black = Color(0xFF111827);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryPurple],
  );

  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightBlue, lightPurple],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentPurple],
  );

  static const LinearGradient panicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [panicRed, dangerRed],
  );

  // Safety Score Colors
  static Color getSafetyScoreColor(int score) {
    if (score >= AppConstants.highSafetyScore) {
      return safeGreen;
    } else if (score >= AppConstants.mediumSafetyScore) {
      return warningOrange;
    } else {
      return dangerRed;
    }
  }
}

class AppTextStyles {
  // Heading Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.darkGray,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.mediumGray,
  );

  // Button Styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Special Styles
  static const TextStyle tagline = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle safetyScore = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const TextStyle panicButton = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 1.0,
  );
}
