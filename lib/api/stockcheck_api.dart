import 'dart:convert';
import 'package:http/http.dart' as http;

class StockCheckApiService {
  final String baseUrl;
  final String token;

  StockCheckApiService({required this.baseUrl, required this.token});

  // Get all stock check notes
  Future<List<StockCheckNote>> getStockCheckNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stock-check'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic>? notesJson = data['data']; // Use nullable type
      if (notesJson == null) {
        return []; // Return an empty list instead of causing an error
      }
      return notesJson.map((json) => StockCheckNote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stock check notes: ${response.statusCode}');
    }
  }

  // Get stock check notes for a specific warehouse
  Future<List<StockCheckNote>> getStockCheckNotesByWarehouse(String warehouseCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stock-check/warehouse/$warehouseCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> notesJson = data['data'];
      return notesJson.map((json) => StockCheckNote.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stock check notes for warehouse $warehouseCode: ${response.statusCode}');
    }
  }

  // Create a new stock check note
  Future<StockCheckNote> createStockCheckNote(StockCheckNoteRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stock-check/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return StockCheckNote.fromJson(data['data']);
    } else {
      throw Exception('Failed to create stock check note: ${response.statusCode}');
    }
  }

  // Approve a stock check note
  Future<StockCheckNote> approveStockCheck(String stockCheckNoteId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/stock-check/approve'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'stockCheckNoteId': stockCheckNoteId,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return StockCheckNote.fromJson(data['data']);
    } else {
      throw Exception('Failed to approve stock check note: ${response.statusCode}');
    }
  }

  // Finalize a stock check note
  Future<StockCheckNote> finalizeStockCheck(String stockCheckNoteId, bool isFinished) async {
    final response = await http.put(
      Uri.parse('$baseUrl/stock-check/finalize/$stockCheckNoteId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'isFinished': isFinished,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return StockCheckNote.fromJson(data['data']);
    } else {
      throw Exception('Failed to finalize stock check note: ${response.statusCode}');
    }
  }

  // Get available warehouses
  Future<List<Warehouse>> getAvailableWarehouses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/warehouses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> warehousesJson = data['data'];
      return warehousesJson.map((json) => Warehouse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load warehouses: ${response.statusCode}');
    }
  }

  // Get available products
  Future<List<Product>> getAvailableProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productsJson = data['data'];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}

// Request models
class StockCheckNoteRequest {
  final String warehouseCode;
  final String description;
  final List<StockCheckProductRequest> stockCheckProducts;

  StockCheckNoteRequest({
    required this.warehouseCode,
    required this.description,
    required this.stockCheckProducts,
  });

  Map<String, dynamic> toJson() {
    return {
      'warehouseCode': warehouseCode,
      'description': description,
      'stockCheckProducts': stockCheckProducts.map((product) => product.toJson()).toList(),
    };
  }
}

class StockCheckProductRequest {
  final String productCode;
  final int actualQuantity;

  StockCheckProductRequest({
    required this.productCode,
    required this.actualQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productCode': productCode,
      'actualQuantity': actualQuantity,
    };
  }
}

// Response models
class StockCheckNote {
  final String stockCheckNoteId;
  final String date;
  final String description;
  final String status;
  final Warehouse warehouse;
  final User checker;
  final List<StockCheckProduct> stockCheckProducts;

  StockCheckNote({
    required this.stockCheckNoteId,
    required this.date,
    required this.description,
    required this.status,
    required this.warehouse,
    required this.checker,
    required this.stockCheckProducts,
  });

  factory StockCheckNote.fromJson(Map<String, dynamic> json) {
    return StockCheckNote(
      stockCheckNoteId: json['stockCheckNoteId'],
      date: json['date'],
      description: json['description'],
      status: json['stockCheckStatus'],
      warehouse: Warehouse.fromJson(json['warehouse']),
      checker: User.fromJson(json['checker']),
      stockCheckProducts: (json['stockCheckProducts'] as List)
          .map((productJson) => StockCheckProduct.fromJson(productJson))
          .toList(),
    );
  }
}

class StockCheckProduct {
  final String stockCheckProductId;
  final Product product;
  final int expectedQuantity;
  final int actualQuantity;

  StockCheckProduct({
    required this.stockCheckProductId,
    required this.product,
    required this.expectedQuantity,
    required this.actualQuantity,
  });

  factory StockCheckProduct.fromJson(Map<String, dynamic> json) {
    return StockCheckProduct(
      stockCheckProductId: json['stockCheckProductId'],
      product: Product.fromJson(json['product']),
      expectedQuantity: json['expectedQuantity'],
      actualQuantity: json['actualQuantity'],
    );
  }
}

class Warehouse {
  final String warehouseId;
  final String warehouseCode;
  final String warehouseName;
  final String address;

  Warehouse({
    required this.warehouseId,
    required this.warehouseCode,
    required this.warehouseName,
    required this.address,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      warehouseId: json['warehouseId'],
      warehouseCode: json['warehouseCode'],
      warehouseName: json['warehouseName'],
      address: json['address'],
    );
  }
}

class Product {
  final String productId;
  final String productCode;
  final String productName;
  final String description;
  final int quantity;

  Product({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.description,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      productCode: json['productCode'],
      productName: json['productName'],
      description: json['description'],
      quantity: json['quantity'],
    );
  }
}

class User {
  final String userId;
  final String email;
  final String fullName;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      fullName: json['fullName'],
    );
  }
}