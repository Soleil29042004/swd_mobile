import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swd_mobile/services/auth_service.dart';

// Stock Response Model
class StockResponse {
  final String productCode;
  final String productName;
  final int totalQuantity;
  final List<WarehouseLocation> warehouses;

  StockResponse({
    required this.productCode,
    required this.productName,
    required this.totalQuantity,
    required this.warehouses,
  });

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      productCode: json['product']['product_code'],
      productName: json['product']['product_name'],
      totalQuantity: json['total_in_warehouses'] ?? 0,
      warehouses: (json['warehouses'] as List)
          .map((w) => WarehouseLocation.fromJson(w))
          .toList(),
    );
  }
}

// Warehouse Location Model
class WarehouseLocation {
  final String warehouseCode;
  final String warehouseName;
  final int totalQuantity;

  WarehouseLocation({
    required this.warehouseCode,
    required this.warehouseName,
    required this.totalQuantity,
  });

  factory WarehouseLocation.fromJson(Map<String, dynamic> json) {
    return WarehouseLocation(
      warehouseCode: json['warehouse_code'],
      warehouseName: json['warehouse_name'],
      totalQuantity: json['total_quantity'] ?? 0,
    );
  }
}

// Product Locations Service
class ProductLocationsService {
  static const String baseUrl = 'https://swd392-be-web-hsdcamfearhyh8ga.eastasia-01.azurewebsites.net/api';
  final AuthService _authService = AuthService(baseUrl: 'https://swd392-be-web-hsdcamfearhyh8ga.eastasia-01.azurewebsites.net/api');

  Future<StockResponse> fetchProductLocations(String productCode) async {
    try {
      // Get the stored token
      final token = await _authService.getToken();

      if (token == null) {
        throw Exception('No authentication token found. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/$productCode/locations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> responseBody = json.decode(response.body);

          if (responseBody['success'] == true && responseBody['data'] != null) {
            return StockResponse.fromJson(responseBody['data']);
          } else {
            throw Exception(responseBody['message'] ?? 'Failed to load product locations');
          }

        case 401:
        // Token might be expired, prompt re-login
          throw Exception('Authentication token expired. Please log in again.');

        case 404:
          throw Exception('Product not found');

        case 400:
          throw Exception('Invalid product code');

        case 500:
          throw Exception('Server error');

        default:
          throw Exception('Unexpected error occurred: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}