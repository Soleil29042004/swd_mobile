import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class HttpService {
  final String baseUrl = 'https://app-250312143530.azurewebsites.net/api';
  final AuthService _authService = AuthService(baseUrl: 'https://app-250312143530.azurewebsites.net/api');

  // GET request with authentication
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Handle token expiration
      if (response.statusCode == 401) {
        // Token expired, redirect to login
        return {
          'success': false,
          'message': 'Session expired. Please login again',
          'requireLogin': true,
        };
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': json.decode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // POST request with authentication
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      // Handle token expiration
      if (response.statusCode == 401) {
        // Token expired, redirect to login
        return {
          'success': false,
          'message': 'Session expired. Please login again',
          'requireLogin': true,
        };
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'data': json.decode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

// Similar methods for PUT, DELETE, etc.
}