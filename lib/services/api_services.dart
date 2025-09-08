import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';

class ApiService {
  static const String baseUrl =
      "https://traveler-safety-app.onrender.com"; // Android emulator
  // For production, use your actual backend URL: "https://traveler-safety-app.onrender.com"

  static String? _authToken;

  // Authentication Token Management
  static Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    return _authToken;
  }

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Helper method to get headers with authentication
  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = true,
  }) async {
    final headers = {"Content-Type": "application/json"};

    if (includeAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    return headers;
  }

  // Authentication APIs
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/signup");
      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": data['message'] ?? "Signup failed"};
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> signin(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/signin");
      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }
        return {"success": true, "data": data};
      } else {
        return {"success": false, "error": data['message'] ?? "Login failed"};
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      await clearAuthToken();
      return {"success": true, "message": "Logged out successfully"};
    } catch (e) {
      return {"success": false, "error": "Logout error: $e"};
    }
  }

  // Tourist Profile APIs
  static Future<Map<String, dynamic>> registerTouristProfile({
    required String name,
    required String phone,
    required String aadhaar,
    String? passport,
    required String destination,
    required String hotel,
    required DateTime checkIn,
    required DateTime checkOut,
    required String emergencyContact1Name,
    required String emergencyContact1Phone,
    required String emergencyContact2Name,
    required String emergencyContact2Phone,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/tourist/register");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "name": name,
          "phone": phone,
          "aadhaar": aadhaar,
          "passport": passport,
          "destination": destination,
          "hotel": hotel,
          "checkIn": checkIn.toIso8601String(),
          "checkOut": checkOut.toIso8601String(),
          "emergencyContacts": [
            {"name": emergencyContact1Name, "phone": emergencyContact1Phone},
            {"name": emergencyContact2Name, "phone": emergencyContact2Phone},
          ],
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getTouristProfile() async {
    try {
      final url = Uri.parse("$baseUrl/tourist/profile");
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Failed to fetch profile",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  // Location and Safety APIs
  static Future<Map<String, dynamic>> updateLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/tourist/location");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Location update failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> sendPanicAlert(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/emergency/panic");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "timestamp": DateTime.now().toIso8601String(),
          "type": "PANIC",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Emergency alert failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getSafetyScore() async {
    try {
      final url = Uri.parse("$baseUrl/tourist/safety-score");
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Failed to fetch safety score",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getSafetyAlerts() async {
    try {
      final url = Uri.parse("$baseUrl/alerts/recent");
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Failed to fetch alerts",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  // Dashboard APIs for Authorities
  static Future<Map<String, dynamic>> dashboardLogin(
    String username,
    String password,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/dashboard/login");
      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['token'] != null) {
          await setAuthToken(data['token']);
        }
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Dashboard login failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final url = Uri.parse("$baseUrl/dashboard/stats");
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Failed to fetch stats",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> getActiveAlerts() async {
    try {
      final url = Uri.parse("$baseUrl/dashboard/alerts");
      final response = await http.get(url, headers: await _getHeaders());

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Failed to fetch alerts",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> generateEFIR(
    Map<String, dynamic> firData,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/dashboard/efir");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(firData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "E-FIR generation failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  static Future<Map<String, dynamic>> sendBroadcastAlert(
    String message,
    String type,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/dashboard/broadcast");
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "message": message,
          "type": type,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Broadcast failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }

  // Utility method to get current location
  static Future<LocationData?> getCurrentLocation() async {
    try {
      Location location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null;
        }
      }

      return await location.getLocation();
    } catch (e) {
      return null;
    }
  }

  // Contact Form API
  static Future<Map<String, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/contact/submit");
      final response = await http.post(
        url,
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({
          "name": name,
          "email": email,
          "subject": subject,
          "message": message,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "error": data['message'] ?? "Message sending failed",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Network error: $e"};
    }
  }
}
