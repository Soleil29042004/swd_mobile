import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StockCheckApi {
  static const String baseUrl = 'https://app-250312143530.azurewebsites.net/api';
  static const String stockCheckEndpoint = '$baseUrl/stock-check';

  // Get auth token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper method to set auth headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new stock check note
  Future<Map<String, dynamic>> createStockCheckNote({
    required String warehouseCode,
    required String description,
    required List<StockCheckProduct> stockCheckProducts,
  }) async {
    try {
      final headers = await _getHeaders();
      final request = {
        'warehouseCode': warehouseCode,
        'description': description,
        'stockCheckProducts': stockCheckProducts
            .map((product) => {
          'productCode': product.productCode,
          'actualQuantity': product.actualQuantity,
        })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$stockCheckEndpoint/create'),
        headers: headers,
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create stock check note: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating stock check note: $e');
    }
  }

  // Get all stock check notes
  Future<List<StockCheckNote>> getAllStockCheckNotes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(stockCheckEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Add null checks for the data
        if (data == null) {
          return [];
        }

        // Add null checks for the result field
        final result = data['result'] as List?;
        if (result == null) {
          return [];
        }

        return result
            .where((item) => item != null) // Filter out null items
            .map((item) => StockCheckNote.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get stock check notes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting stock check notes: $e');
    }
  }

  // Get stock check notes by warehouse
  Future<List<StockCheckNote>> getStockCheckNotesByWarehouse(String warehouseCode) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$stockCheckEndpoint/warehouse/$warehouseCode'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Add null checks for the data
        if (data == null) {
          return [];
        }

        // Add null checks for the result field
        final result = data['result'] as List?;
        if (result == null) {
          return [];
        }

        return result
            .where((item) => item != null) // Filter out null items
            .map((item) => StockCheckNote.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to get stock check notes for warehouse: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting stock check notes for warehouse: $e');
    }
  }

  // Approve a stock check note
  Future<StockCheckNote> approveStockCheck(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$stockCheckEndpoint/approve/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data['result'] == null) {
          throw Exception('Invalid response data');
        }
        return StockCheckNote.fromJson(data['result']);
      } else {
        throw Exception('Failed to approve stock check: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error approving stock check: $e');
    }
  }

  // Finalize a stock check note
  Future<StockCheckNote> finalizeStockCheck(String id, bool isFinished) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$stockCheckEndpoint/finalize/$id?isFinished=$isFinished'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data == null || data['result'] == null) {
          throw Exception('Invalid response data');
        }
        return StockCheckNote.fromJson(data['result']);
      } else {
        throw Exception('Failed to finalize stock check: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error finalizing stock check: $e');
    }
  }
}

// Model classes to handle stock check data
class StockCheckNote {
  final String stockCheckNoteId;
  final String date;
  final String warehouseCode;
  final String warehouseName;
  final String checkerName;
  final String stockCheckStatus;
  final String description;
  final List<StockCheckProduct> stockCheckProducts;

  StockCheckNote({
    required this.stockCheckNoteId,
    required this.date,
    required this.warehouseCode,
    required this.warehouseName,
    required this.checkerName,
    required this.stockCheckStatus,
    this.description = '',
    required this.stockCheckProducts,
  });

  factory StockCheckNote.fromJson(Map<String, dynamic> json) {
    return StockCheckNote(
      stockCheckNoteId: json['stockCheckNoteId'] ?? '',
      date: json['date'] ?? '',
      warehouseCode: json['warehouseCode'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
      checkerName: json['checkerName'] ?? '',
      stockCheckStatus: json['stockCheckStatus'] ?? '',
      description: json['description'] ?? '',
      stockCheckProducts: json['stockCheckProducts'] != null
          ? (json['stockCheckProducts'] as List)
          .where((item) => item != null)
          .map((item) => StockCheckProduct.fromJson(item))
          .toList()
          : [],
    );
  }

  // Update toJson method to match the new structure
  Map<String, dynamic> toJson() {
    return {
      'stockCheckNoteId': stockCheckNoteId,
      'date': date,
      'warehouseCode': warehouseCode,
      'warehouseName': warehouseName,
      'checkerName': checkerName,
      'stockCheckStatus': stockCheckStatus,
      'description': description,
      'stockCheckProducts': stockCheckProducts.map((item) => item.toJson()).toList(),
    };
  }
}

class StockCheckProduct {
  final String? productCode;
  final String? productName;
  final int lastQuantity;
  final int totalImportQuantity;
  final int totalExportQuantity;
  final int expectedQuantity;
  final int actualQuantity;
  final int difference;

  StockCheckProduct({
    this.productCode,
    this.productName,
    required this.lastQuantity,
    required this.totalImportQuantity,
    required this.totalExportQuantity,
    required this.expectedQuantity,
    required this.actualQuantity,
    required this.difference,
  });

  factory StockCheckProduct.fromJson(Map<String, dynamic> json) {
    if (json == null) return StockCheckProduct.empty();

    return StockCheckProduct(
      productCode: json['productCode'],
      productName: json['productName'],
      lastQuantity: json['lastQuantity'] ?? 0,
      totalImportQuantity: json['totalImportQuantity'] ?? 0,
      totalExportQuantity: json['totalExportQuantity'] ?? 0,
      expectedQuantity: json['expectedQuantity'] ?? 0,
      actualQuantity: json['actualQuantity'] ?? 0,
      difference: json['difference'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productCode': productCode,
      'productName': productName,
      'lastQuantity': lastQuantity,
      'totalImportQuantity': totalImportQuantity,
      'totalExportQuantity': totalExportQuantity,
      'expectedQuantity': expectedQuantity,
      'actualQuantity': actualQuantity,
      'difference': difference,
    };
  }

  // Add empty constructor for handling null cases
  factory StockCheckProduct.empty() {
    return StockCheckProduct(
      productCode: null,
      productName: null,
      lastQuantity: 0,
      totalImportQuantity: 0,
      totalExportQuantity: 0,
      expectedQuantity: 0,
      actualQuantity: 0,
      difference: 0,
    );
  }
}

class WarehouseInfo {
  final String warehouseId;
  final String warehouseCode;
  final String warehouseName;

  WarehouseInfo({
    required this.warehouseId,
    required this.warehouseCode,
    required this.warehouseName,
  });

  // Add empty constructor for handling null cases
  factory WarehouseInfo.empty() {
    return WarehouseInfo(
      warehouseId: '',
      warehouseCode: '',
      warehouseName: '',
    );
  }

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return WarehouseInfo.empty();

    return WarehouseInfo(
      warehouseId: json['warehouseId'] ?? '',
      warehouseCode: json['warehouseCode'] ?? '',
      warehouseName: json['warehouseName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseId': warehouseId,
      'warehouseCode': warehouseCode,
      'warehouseName': warehouseName,
    };
  }
}

class UserInfo {
  final String userId;
  final String name;
  final String email;

  UserInfo({
    required this.userId,
    required this.name,
    required this.email,
  });

  // Add empty constructor for handling null cases
  factory UserInfo.empty() {
    return UserInfo(
      userId: '',
      name: '',
      email: '',
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return UserInfo.empty();

    return UserInfo(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }
}

class ProductInfo {
  final String productId;
  final String productCode;
  final String productName;

  ProductInfo({
    required this.productId,
    required this.productCode,
    required this.productName,
  });

  // Add empty constructor for handling null cases
  factory ProductInfo.empty() {
    return ProductInfo(
      productId: '',
      productCode: '',
      productName: '',
    );
  }

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    if (json == null) return ProductInfo.empty();

    return ProductInfo(
      productId: json['productId'] ?? '',
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productCode': productCode,
      'productName': productName,
    };
  }
}