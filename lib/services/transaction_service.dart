import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swd_mobile/services/auth_service.dart';

enum TransactionType { IMPORT, EXPORT }
enum StockExchangeStatus { pending, accepted, rejected, finished }

// Convert enum to string for API
extension TransactionTypeExtension on TransactionType {
  String get value {
    return this.toString().split('.').last;
  }
}

extension StockExchangeStatusExtension on StockExchangeStatus {
  String get value {
    return this.toString().split('.').last;
  }
}

class StockExchangeRequest {
  final String? transactionId;
  final TransactionType transactionType;
  final String? sourceWarehouseCode;
  final String? destinationWarehouseCode;
  final List<TransactionItemRequest> items;

  StockExchangeRequest({
    this.transactionId,
    required this.transactionType,
    this.sourceWarehouseCode,
    this.destinationWarehouseCode,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      if (transactionId != null) 'transactionId': transactionId,
      'transactionType': transactionType.value,
      if (sourceWarehouseCode != null) 'sourceWarehouseCode': sourceWarehouseCode,
      if (destinationWarehouseCode != null) 'destinationWarehouseCode': destinationWarehouseCode,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class TransactionItemRequest {
  final String? noteItemCode;
  final String productCode;
  final int quantity;

  TransactionItemRequest({
    this.noteItemCode,
    required this.productCode,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      if (noteItemCode != null) 'noteItemCode': noteItemCode,
      'productCode': productCode,
      'quantity': quantity,
    };
  }
}

class ApiResponse<T> {
  final int code;
  final String message;
  final T result;

  ApiResponse({
    required this.code,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      result: fromJsonT(json['result']),
    );
  }
}

class StockExchangeResponse {
  final String transactionId;
  final TransactionType transactionType;
  final String? sourceWarehouseCode;
  final String? destinationWarehouseCode;
  final String createdBy;
  final StockExchangeStatus status;
  final String? approvedBy;
  final List<NoteItemResponse>? items;

  StockExchangeResponse({
    required this.transactionId,
    required this.transactionType,
    this.sourceWarehouseCode,
    this.destinationWarehouseCode,
    required this.createdBy,
    required this.status,
    this.approvedBy,
    this.items,
  });

  factory StockExchangeResponse.fromJson(Map<String, dynamic> json) {
    // First check if the json is null or empty
    if (json == null) {
      throw Exception('Cannot create StockExchangeResponse from null');
    }

    // More robust null handling for required fields
    final String transactionId = json['transactionId']?.toString() ?? '';
    final String createdBy = json['createdBy']?.toString() ?? '';

    return StockExchangeResponse(
      transactionId: transactionId,
      transactionType: json['transactionType'] != null
          ? TransactionType.values.firstWhere(
            (e) => e.value == json['transactionType'],
        orElse: () => TransactionType.IMPORT,
      )
          : TransactionType.IMPORT,
      sourceWarehouseCode: json['sourceWarehouseCode']?.toString(),
      destinationWarehouseCode: json['destinationWarehouseCode']?.toString(),
      createdBy: createdBy,
      approvedBy: json['approvedBy']?.toString(),
      status: json['status'] != null
          ? StockExchangeStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
        orElse: () => StockExchangeStatus.pending,
      )
          : StockExchangeStatus.pending,
      items: json['items'] != null
          ? (json['items'] as List)
          .map((item) => NoteItemResponse.fromJson(item))
          .toList()
          : null,
    );
  }
}

class NoteItemResponse {
  final String noteItemId;
  final String noteItemCode;
  final String productCode;
  final String productName;
  final int quantity;
  final String warehouseCode;

  NoteItemResponse({
    required this.noteItemId,
    required this.noteItemCode,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.warehouseCode,
  });

  factory NoteItemResponse.fromJson(Map<String, dynamic> json) {
    return NoteItemResponse(
      noteItemId: json['noteItemId']?.toString() ?? '',
      noteItemCode: json['noteItemCode']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 0,
      warehouseCode: json['warehouseCode']?.toString() ?? '',
    );
  }
}

class StockTransactionService {
  final String baseUrl;
  final AuthService authService;

  StockTransactionService({
    required this.baseUrl,
    required this.authService,
  });

  // Get headers with the latest auth token
  Future<Map<String, String>> get _getHeaders async {
    final token = await authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create a stock transaction (import or export)
  Future<StockExchangeResponse> createTransaction(StockExchangeRequest request) async {
    try {
      // Get the latest token for the request
      final headers = await _getHeaders;

      print("Creating transaction with headers: $headers");
      print("Request body: ${jsonEncode(request.toJson())}");

      final response = await http.post(
        Uri.parse('$baseUrl/transactions/create'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      print("Transaction API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StockExchangeResponse.fromJson(responseData['result']);
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Transaction API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to create transaction: ${response.body}');
      }
    } catch (e) {
      print("Exception in createTransaction: $e");
      rethrow;
    }
  }

  // Approve a transaction
  Future<StockExchangeResponse> approveTransaction(String id, {bool includeItems = true}) async {
    try {
      final headers = await _getHeaders;

      print("Approving transaction with ID: $id, includeItems: $includeItems");

      final uri = Uri.parse('$baseUrl/transactions/approve/$id')
          .replace(queryParameters: {'includeItems': includeItems.toString()});

      final response = await http.post(
        uri,
        headers: headers,
      );

      print("Approve Transaction API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StockExchangeResponse.fromJson(responseData['result']);
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Approve Transaction API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to approve transaction: ${response.body}');
      }
    } catch (e) {
      print("Exception in approveTransaction: $e");
      rethrow;
    }
  }

  // Finalize a transaction (set as finished or rejected)
  Future<StockExchangeResponse> finalizeTransaction(String id, {required bool isFinished, bool includeItems = true}) async {
    try {
      final headers = await _getHeaders;

      print("Finalizing transaction with ID: $id, isFinished: $isFinished, includeItems: $includeItems");

      final uri = Uri.parse('$baseUrl/transactions/finalize/$id')
          .replace(queryParameters: {
        'isFinished': isFinished.toString(),
        'includeItems': includeItems.toString(),
      });

      final response = await http.post(
        uri,
        headers: headers,
      );

      print("Finalize Transaction API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StockExchangeResponse.fromJson(responseData['result']);
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Finalize Transaction API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to finalize transaction: ${response.body}');
      }
    } catch (e) {
      print("Exception in finalizeTransaction: $e");
      rethrow;
    }
  }


  // Cancel a transaction
  Future<StockExchangeResponse> cancelTransaction(String transactionId) async {
    try {
      final headers = await _getHeaders;

      print("Canceling transaction with ID: $transactionId");

      final response = await http.post(
        Uri.parse('$baseUrl/transactions/cancel/$transactionId'),
        headers: headers,
      );

      print("Cancel Transaction API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StockExchangeResponse.fromJson(responseData['result']);
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Cancel Transaction API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to cancel transaction: ${response.body}');
      }
    } catch (e) {
      print("Exception in cancelTransaction: $e");
      rethrow;
    }
  }

  // Get all transactions
  Future<List<StockExchangeResponse>> getAllTransactions() async {
    try {
      final headers = await _getHeaders;
      print("Getting all transactions");

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/all'),
        headers: headers,
      );

      print("Get All Transactions API Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> resultList = responseData['result'];

        // Debug the API response
        print("API Result: $resultList");

        for (var item in resultList) {
          // Check for null fields that should be non-null
          print("Checking item: ${item['transactionId']}");
          if (item['transactionId'] == null) {
            print("WARNING: transactionId is null");
          }
          if (item['createdBy'] == null) {
            print("WARNING: createdBy is null");
          }
        }

        return resultList
            .map((item) => StockExchangeResponse.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Get All Transactions API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to get transactions: ${response.body}');
      }
    } catch (e) {
      print("Exception in getAllTransactions: $e");
      rethrow;
    }
  }

  // Get transactions by warehouse
  Future<List<StockExchangeResponse>> getTransactionsByWarehouse(String warehouseCode) async {
    try {
      final headers = await _getHeaders;

      print("Getting transactions for warehouse: $warehouseCode");

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/warehouse/$warehouseCode'),
        headers: headers,
      );

      print("Get Warehouse Transactions API Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> resultList = responseData['result'];
        return resultList
            .map((item) => StockExchangeResponse.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Get Warehouse Transactions API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to get warehouse transactions: ${response.body}');
      }
    } catch (e) {
      print("Exception in getTransactionsByWarehouse: $e");
      rethrow;
    }
  }

  // Get pending transactions
  Future<List<StockExchangeResponse>> getPendingTransactions() async {
    try {
      final headers = await _getHeaders;

      print("Getting pending transactions");

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/pending'),
        headers: headers,
      );

      print("Get Pending Transactions API Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> resultList = responseData['result'];
        return resultList
            .map((item) => StockExchangeResponse.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Get Pending Transactions API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to get pending transactions: ${response.body}');
      }
    } catch (e) {
      print("Exception in getPendingTransactions: $e");
      rethrow;
    }
  }

  // Get transaction by ID
  Future<StockExchangeResponse> getTransactionById(String transactionId) async {
    try {
      final headers = await _getHeaders;

      print("Getting transaction with ID: $transactionId");

      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$transactionId'),
        headers: headers,
      );

      print("Get Transaction API Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return StockExchangeResponse.fromJson(responseData['result']);
      } else if (response.statusCode == 401) {
        // Authentication issue
        print("Authentication error: ${response.body}");

        // Check if token is still valid
        final token = await authService.getToken();
        if (token != null) {
          final isValid = await authService.validateToken(token);
          if (!isValid) {
            // Token is invalid, clear it
            await authService.logout();
          }
        }

        throw Exception('Authentication error - please log in again');
      } else {
        print("Get Transaction API error: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to get transaction: ${response.body}');
      }
    } catch (e) {
      print("Exception in getTransactionById: $e");
      rethrow;
    }
  }

}