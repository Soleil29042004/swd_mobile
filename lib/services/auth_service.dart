import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl;

  // Constructor with baseUrl parameter
  AuthService({required this.baseUrl});

  // Login method using the API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("Login API Response: ${response.body}"); // Debug API response

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('result') && data['result'] != null) {
          final Map<String, dynamic> result = data['result'];

          if (result.containsKey('token') && result['token'] != null) {
            print("Received Token: ${result['token']}"); // Debug print

            // Save token and user info
            await _saveUserData(result);

            return {
              'success': true,
              'data': result,
            };
          } else {
            print("Error: Token is missing inside result object");
          }
        }

        return {
          'success': false,
          'message': 'Invalid credentials or missing token',
        };
      } else {
        Map<String, dynamic>? errorData;
        try {
          errorData = jsonDecode(response.body);
        } catch (_) {}

        return {
          'success': false,
          'message': errorData?['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      print("Login exception: ${e.toString()}");
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Check token validity
  Future<bool> validateToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/introspect'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
      return false;
    } catch (e) {
      print("Token validation error: ${e.toString()}");
      return false;
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data['token'] ?? '');
    await prefs.setBool('authenticated', data['authenticated'] ?? false);
    await prefs.setString('userCode', data['userCode'] ?? '');
    await prefs.setString('email', data['email'] ?? '');
    await prefs.setString('fullName', data['fullName'] ?? '');
    await prefs.setString('userName', data['userName'] ?? '');

    // Save role info if available
    if (data['role'] != null) {
      await prefs.setString('roleId', data['role']['roleId'] ?? '');
      await prefs.setString('roleType', data['role']['roleType'] ?? '');
      await prefs.setString('roleName', data['role']['roleName'] ?? '');
    }
  }

  // Check if user is logged in and token is valid
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // Validate the token
      return await validateToken(token);
    }
    return false;
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user details
  Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userCode': prefs.getString('userCode'),
      'email': prefs.getString('email'),
      'fullName': prefs.getString('fullName'),
      'userName': prefs.getString('userName'),
      'roleType': prefs.getString('roleType'),
      'roleName': prefs.getString('roleName'),
    };
  }

  // Clear all user data on logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('authenticated');
    await prefs.remove('userCode');
    await prefs.remove('email');
    await prefs.remove('fullName');
    await prefs.remove('userName');
    await prefs.remove('roleId');
    await prefs.remove('roleType');
    await prefs.remove('roleName');
  }
}
