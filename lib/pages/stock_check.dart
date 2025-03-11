import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swd_mobile/components.dart';

// Enums
enum StockCheckStatus {
  pending,
  accepted,
  finished,
  rejected;

  String toJson() => name;

  static StockCheckStatus fromJson(String json) {
    return StockCheckStatus.values.firstWhere(
          (e) => e.name == json,
      orElse: () => StockCheckStatus.pending,
    );
  }
}

// Models
class StockCheckProduct {
  final String productCode;
  final int actualQuantity;
  final int expectedQuantity;
  final String? productName;

  StockCheckProduct({
    required this.productCode,
    required this.actualQuantity,
    this.expectedQuantity = 0,
    this.productName,
  });

  Map<String, dynamic> toJson() {
    return {
      'productCode': productCode,
      'actualQuantity': actualQuantity,
    };
  }

  factory StockCheckProduct.fromJson(Map<String, dynamic> json) {
    return StockCheckProduct(
      productCode: json['productCode'],
      actualQuantity: json['actualQuantity'] ?? 0,
      expectedQuantity: json['expectedQuantity'] ?? 0,
      productName: json['productName'],
    );
  }
}

class StockCheckNote {
  final String? stockCheckNoteId;
  final DateTime date;
  final String warehouseCode;
  final String? warehouseName;
  final String? checkerName;
  final StockCheckStatus status;
  final List<StockCheckProduct> stockCheckProducts;
  final String? description;

  StockCheckNote({
    this.stockCheckNoteId,
    required this.date,
    required this.warehouseCode,
    this.warehouseName,
    this.checkerName,
    this.status = StockCheckStatus.pending,
    required this.stockCheckProducts,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'warehouseCode': warehouseCode,
      'description': description,
      'stockCheckProducts': stockCheckProducts.map((product) => product.toJson()).toList(),
    };
  }

  factory StockCheckNote.fromJson(Map<String, dynamic> json) {
    return StockCheckNote(
      stockCheckNoteId: json['stockCheckNoteId'],
      date: DateTime.parse(json['date']),
      warehouseCode: json['warehouseCode'],
      warehouseName: json['warehouseName'],
      checkerName: json['checkerName'],
      status: StockCheckStatus.fromJson(json['stockCheckStatus']),
      stockCheckProducts: (json['stockCheckProducts'] as List)
          .map((item) => StockCheckProduct.fromJson(item))
          .toList(),
    );
  }
}

// Mock Data Service
class StockCheckDataService {
  // Mock data for stock check notes
  static List<StockCheckNote> getMockStockCheckNotes() {
    return [
      // Mock data: First stock check note
      StockCheckNote(
        stockCheckNoteId: 'SC-001',
        date: DateTime.now().subtract(Duration(days: 5)),
        warehouseCode: 'WH-001',
        warehouseName: 'Main Warehouse',
        checkerName: 'John Doe',
        status: StockCheckStatus.pending,
        description: 'Monthly inventory check',
        stockCheckProducts: [
          // Mock product data
          StockCheckProduct(
            productCode: 'P-001',
            productName: 'Product One',
            actualQuantity: 95,
            expectedQuantity: 100,
          ),
          // Mock product data
          StockCheckProduct(
            productCode: 'P-002',
            productName: 'Product Two',
            actualQuantity: 50,
            expectedQuantity: 50,
          ),
        ],
      ),
      // Mock data: Second stock check note
      StockCheckNote(
        stockCheckNoteId: 'SC-002',
        date: DateTime.now().subtract(Duration(days: 10)),
        warehouseCode: 'WH-002',
        warehouseName: 'Secondary Warehouse',
        checkerName: 'Jane Smith',
        status: StockCheckStatus.accepted,
        description: 'Weekly inventory check',
        stockCheckProducts: [
          // Mock product data
          StockCheckProduct(
            productCode: 'P-003',
            productName: 'Product Three',
            actualQuantity: 75,
            expectedQuantity: 80,
          ),
        ],
      ),
      // Mock data: Third stock check note
      StockCheckNote(
        stockCheckNoteId: 'SC-003',
        date: DateTime.now().subtract(Duration(days: 15)),
        warehouseCode: 'WH-001',
        warehouseName: 'Main Warehouse',
        checkerName: 'Mike Johnson',
        status: StockCheckStatus.finished,
        description: 'Quarterly audit',
        stockCheckProducts: [
          // Mock product data
          StockCheckProduct(
            productCode: 'P-001',
            productName: 'Product One',
            actualQuantity: 98,
            expectedQuantity: 100,
          ),
          // Mock product data
          StockCheckProduct(
            productCode: 'P-004',
            productName: 'Product Four',
            actualQuantity: 120,
            expectedQuantity: 115,
          ),
          // Mock product data
          StockCheckProduct(
            productCode: 'P-005',
            productName: 'Product Five',
            actualQuantity: 78,
            expectedQuantity: 80,
          ),
        ],
      ),
      // Mock data: Fourth stock check note
      StockCheckNote(
        stockCheckNoteId: 'SC-004',
        date: DateTime.now().subtract(Duration(days: 20)),
        warehouseCode: 'WH-003',
        warehouseName: 'Storage Warehouse',
        checkerName: 'Sarah Lee',
        status: StockCheckStatus.rejected,
        description: 'Emergency check after system failure',
        stockCheckProducts: [
          // Mock product data
          StockCheckProduct(
            productCode: 'P-002',
            productName: 'Product Two',
            actualQuantity: 45,
            expectedQuantity: 55,
          ),
        ],
      ),
    ];
  }

  // Mock data for available warehouses
  static List<String> getAvailableWarehouses() {
    // Mock warehouse codes
    return ['WH-001', 'WH-002', 'WH-003'];
  }

  // Mock data for available products
  static List<Map<String, dynamic>> getAvailableProducts() {
    // Mock product list
    return [
      {'productCode': 'P-001', 'productName': 'Product One'},
      {'productCode': 'P-002', 'productName': 'Product Two'},
      {'productCode': 'P-003', 'productName': 'Product Three'},
      {'productCode': 'P-004', 'productName': 'Product Four'},
      {'productCode': 'P-005', 'productName': 'Product Five'},
    ];
  }

  // Mock function to simulate submitting a new stock check note
  static Future<bool> submitStockCheckNote(StockCheckNote note) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  // Mock function to simulate approving a stock check note
  static Future<bool> approveStockCheckNote(String noteId, bool isApproved) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}

// Main Stock Check Screen (Entry Point)
class StockCheckMainScreen extends StatefulWidget {
  const StockCheckMainScreen({Key? key}) : super(key: key);

  @override
  State<StockCheckMainScreen> createState() => _StockCheckMainScreenState();
}

class _StockCheckMainScreenState extends State<StockCheckMainScreen> {
  // Mock navigation drawer state
  Map<String, bool> _drawerSectionState = {
    "Home": false,
    "Xuất-nhập ngoại": false,
    "Xuất-nhập nội": false,
    "Quản lý hàng hóa": false,
  };

  List<StockCheckNote> _stockCheckNotes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStockCheckNotes();
  }

  Future<void> _loadStockCheckNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));

      // Get mock data
      final notes = StockCheckDataService.getMockStockCheckNotes();

      setState(() {
        _stockCheckNotes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load stock check notes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApprove(String noteId, bool isApproved) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call mock service
      final success = await StockCheckDataService.approveStockCheckNote(noteId, isApproved);

      if (success) {
        // Update the status in the local list
        setState(() {
          final index = _stockCheckNotes.indexWhere((note) => note.stockCheckNoteId == noteId);
          if (index != -1) {
            final updatedNote = StockCheckNote(
              stockCheckNoteId: _stockCheckNotes[index].stockCheckNoteId,
              date: _stockCheckNotes[index].date,
              warehouseCode: _stockCheckNotes[index].warehouseCode,
              warehouseName: _stockCheckNotes[index].warehouseName,
              checkerName: _stockCheckNotes[index].checkerName,
              status: isApproved ? StockCheckStatus.accepted : StockCheckStatus.rejected,
              stockCheckProducts: _stockCheckNotes[index].stockCheckProducts,
              description: _stockCheckNotes[index].description,
            );

            _stockCheckNotes[index] = updatedNote;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock check ${isApproved ? 'approved' : 'rejected'} successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update stock check: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCreateScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockCheckCreateScreen(
          availableWarehouses: StockCheckDataService.getAvailableWarehouses(),
          availableProducts: StockCheckDataService.getAvailableProducts(),
          onSubmit: _handleSubmitNewStockCheck,
        ),
      ),
    ).then((_) => _loadStockCheckNotes());
  }

  void _navigateToDetailScreen(StockCheckNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockCheckDetailScreen(
          stockCheckNote: note,
          onApprove: _handleApprove,
        ),
      ),
    ).then((_) => _loadStockCheckNotes());
  }

  Future<void> _handleSubmitNewStockCheck(StockCheckNote note) async {
    try {
      final success = await StockCheckDataService.submitStockCheckNote(note);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock check note created successfully')),
        );
        _loadStockCheckNotes();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create stock check note: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildNavigationDrawer(context, _drawerSectionState, setState),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
          : StockCheckListScreen(
        stockCheckNotes: _stockCheckNotes,
        onRefresh: _loadStockCheckNotes,
        onApprove: _handleApprove,
        onCreateNew: _navigateToCreateScreen,
        onViewDetail: _navigateToDetailScreen,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// UI Components (updated to use mock data and handle navigation)
class StockCheckListScreen extends StatelessWidget {
  final String? warehouseCode;
  final List<StockCheckNote> stockCheckNotes;
  final Function() onRefresh;
  final Function(String noteId, bool isApproved) onApprove;
  final Function() onCreateNew;
  final Function(StockCheckNote note) onViewDetail;

  const StockCheckListScreen({
    Key? key,
    this.warehouseCode,
    required this.stockCheckNotes,
    required this.onRefresh,
    required this.onApprove,
    required this.onCreateNew,
    required this.onViewDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return stockCheckNotes.isEmpty
        ? const Center(child: Text('No stock check notes found'))
        : RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        itemCount: stockCheckNotes.length,
        itemBuilder: (context, index) {
          final note = stockCheckNotes[index];
          return StockCheckListItem(
            stockCheckNote: note,
            onApprove: note.status == StockCheckStatus.pending
                ? () => onApprove(note.stockCheckNoteId!, true)
                : null,
            onTap: () => onViewDetail(note),
          );
        },
      ),
    );
  }
}

class StockCheckListItem extends StatelessWidget {
  final StockCheckNote stockCheckNote;
  final VoidCallback? onApprove;
  final VoidCallback? onTap;

  const StockCheckListItem({
    Key? key,
    required this.stockCheckNote,
    this.onApprove,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Stock Check: ${stockCheckNote.warehouseName ?? stockCheckNote.warehouseCode}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd').format(stockCheckNote.date)}'),
            Text('Status: ${stockCheckNote.status.name}'),
            Text('Products: ${stockCheckNote.stockCheckProducts.length}'),
            if (stockCheckNote.description != null && stockCheckNote.description!.isNotEmpty)
              Text('Note: ${stockCheckNote.description}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: stockCheckNote.status == StockCheckStatus.pending && onApprove != null
            ? ElevatedButton(
          onPressed: onApprove,
          child: const Text('Approve'),
        )
            : _getStatusIcon(stockCheckNote.status),
        onTap: onTap,
      ),
    );
  }

  Widget _getStatusIcon(StockCheckStatus status) {
    switch (status) {
      case StockCheckStatus.pending:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case StockCheckStatus.accepted:
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case StockCheckStatus.finished:
        return const Icon(Icons.check_circle, color: Colors.green);
      case StockCheckStatus.rejected:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }
}

class StockCheckDetailScreen extends StatelessWidget {
  final StockCheckNote stockCheckNote;
  final Function(String noteId, bool isApproved) onApprove;

  const StockCheckDetailScreen({
    Key? key,
    required this.stockCheckNote,
    required this.onApprove
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${stockCheckNote.stockCheckNoteId}'),
                    const SizedBox(height: 8),
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(stockCheckNote.date)}'),
                    const SizedBox(height: 8),
                    Text('Warehouse: ${stockCheckNote.warehouseName ?? stockCheckNote.warehouseCode}'),
                    const SizedBox(height: 8),
                    Text('Checker: ${stockCheckNote.checkerName ?? 'Unknown'}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        _buildStatusChip(stockCheckNote.status),
                      ],
                    ),
                    if (stockCheckNote.description != null && stockCheckNote.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Description: ${stockCheckNote.description}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stockCheckNote.stockCheckProducts.length,
              itemBuilder: (context, index) {
                final product = stockCheckNote.stockCheckProducts[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName ?? product.productCode,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('Product Code: ${product.productCode}'),
                              const SizedBox(height: 4),
                              Text('Expected: ${product.expectedQuantity}'),
                              const SizedBox(height: 4),
                              Text('Actual: ${product.actualQuantity}'),
                              const SizedBox(height: 4),
                              Text(
                                'Difference: ${product.actualQuantity - product.expectedQuantity}',
                                style: TextStyle(
                                  color: product.actualQuantity < product.expectedQuantity
                                      ? Colors.red
                                      : product.actualQuantity > product.expectedQuantity
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (stockCheckNote.status == StockCheckStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onApprove(stockCheckNote.stockCheckNoteId!, true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Approve'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      onApprove(stockCheckNote.stockCheckNoteId!, false);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(StockCheckStatus status) {
    Color color;
    switch (status) {
      case StockCheckStatus.pending:
        color = Colors.orange;
        break;
      case StockCheckStatus.accepted:
        color = Colors.blue;
        break;
      case StockCheckStatus.finished:
        color = Colors.green;
        break;
      case StockCheckStatus.rejected:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}

class StockCheckCreateScreen extends StatefulWidget {
  final String? warehouseCode;
  final List<String> availableWarehouses;
  final List<Map<String, dynamic>> availableProducts;
  final Function(StockCheckNote note) onSubmit;

  const StockCheckCreateScreen({
    Key? key,
    this.warehouseCode,
    required this.availableWarehouses,
    required this.availableProducts,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<StockCheckCreateScreen> createState() => _StockCheckCreateScreenState();
}

class _StockCheckCreateScreenState extends State<StockCheckCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedWarehouseCode = '';
  List<StockCheckProduct> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.warehouseCode != null) {
      _selectedWarehouseCode = widget.warehouseCode!;
    } else if (widget.availableWarehouses.isNotEmpty) {
      _selectedWarehouseCode = widget.availableWarehouses.first;
    }

    // Add one empty product by default
    _products.add(StockCheckProduct(
      productCode: widget.availableProducts.isNotEmpty ? widget.availableProducts.first['productCode'] : '',
      actualQuantity: 0,
    ));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      _products.add(StockCheckProduct(
        productCode: widget.availableProducts.isNotEmpty ? widget.availableProducts.first['productCode'] : '',
        actualQuantity: 0,
      ));
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _products.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final stockCheckNote = StockCheckNote(
          date: DateTime.now(),
          warehouseCode: _selectedWarehouseCode,
          description: _descriptionController.text,
          stockCheckProducts: _products,
        );

        widget.onSubmit(stockCheckNote);

        Navigator.pop(context);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warehouse Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Warehouse',
                  border: OutlineInputBorder(),
                ),
                value: _selectedWarehouseCode,
                items: widget.availableWarehouses
                    .map((warehouse) => DropdownMenuItem<String>(
                  value: warehouse,
                  child: Text(warehouse),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWarehouseCode = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a warehouse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(index);
                },
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  onPressed: _submitForm,
                  child: const Text('Submit Stock Check'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(int index) {
    final product = _products[index];

    // Find product name for display
    String? productName;
    if (product.productCode.isNotEmpty) {
      final productData = widget.availableProducts.firstWhere(
              (p) => p['productCode'] == product.productCode,
          orElse: () => {'productName': ''});
      productName = productData['productName'];
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_products.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeProduct(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
              value: product.productCode.isNotEmpty ? product.productCode : null,
              items: widget.availableProducts
                  .map((product) => DropdownMenuItem<String>(
                value: product['productCode'],
                child: Text('${product['productName']} (${product['productCode']})'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _products[index] = StockCheckProduct(
                    productCode: value!,
                    actualQuantity: product.actualQuantity,
                    productName: productName,
                  );
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a product';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Actual Quantity
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Actual Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: product.actualQuantity.toString(),
              onChanged: (value) {
                setState(() {
                  _products[index] = StockCheckProduct(
                    productCode: product.productCode,
                    actualQuantity: int.tryParse(value) ?? 0,
                    productName: productName,
                  );
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (int.parse(value) < 0) {
                  return 'Quantity cannot be negative';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Main entry point that would go in your main.dart or routes
class StockCheckScreen extends StatelessWidget {
  const StockCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StockCheckMainScreen();
  }
}