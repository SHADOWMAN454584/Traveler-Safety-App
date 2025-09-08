import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5000"; // For Android emulator
  // ⚠️ If testing on real phone, replace with your PC’s local IP (e.g. 192.168.1.5)

  static Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {"success": true, "data": data};
    } else {
      return {"success": false, "error": data['error'] ?? "Unknown error"};
    }
  }
}
