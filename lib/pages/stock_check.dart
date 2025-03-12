import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swd_mobile/api/stockcheck_api.dart';
import 'package:swd_mobile/components.dart';

// Enums (replace this with the API's status representation)
enum StockCheckStatus {
  pending,
  accepted,
  finished,
  rejected;

  String toJson() => name;

  static StockCheckStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StockCheckStatus.pending;
      case 'accepted':
        return StockCheckStatus.accepted;
      case 'finished':
        return StockCheckStatus.finished;
      case 'rejected':
        return StockCheckStatus.rejected;
      default:
        return StockCheckStatus.pending;
    }
  }
}

// Main Stock Check Screen (Entry Point)
class StockCheckMainScreen extends StatefulWidget {
  final StockCheckApiService apiService;

  const StockCheckMainScreen({
    Key? key,
    required this.apiService
  }) : super(key: key);

  @override
  State<StockCheckMainScreen> createState() => _StockCheckMainScreenState();
}

class _StockCheckMainScreenState extends State<StockCheckMainScreen> {
  // Navigation drawer state
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
      final notes = await widget.apiService.getStockCheckNotes();

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

  Future<void> _handleApprove(String noteId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.apiService.approveStockCheck(noteId);

      // Reload data after approval
      await _loadStockCheckNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock check approved successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve stock check: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleFinalize(String noteId, bool isFinished) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.apiService.finalizeStockCheck(noteId, isFinished);

      // Reload data after finalization
      await _loadStockCheckNotes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock check ${isFinished ? 'finished' : 'rejected'} successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update stock check: ${e.toString()}')),
      );
    }
  }

  void _navigateToCreateScreen() async {
    try {
      // Get warehouses and products from API
      final warehouses = await widget.apiService.getAvailableWarehouses();
      final products = await widget.apiService.getAvailableProducts();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StockCheckCreateScreen(
            availableWarehouses: warehouses,
            availableProducts: products,
            onSubmit: _handleSubmitNewStockCheck,
            apiService: widget.apiService,
          ),
        ),
      ).then((_) => _loadStockCheckNotes());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  void _navigateToDetailScreen(StockCheckNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockCheckDetailScreen(
          stockCheckNote: note,
          onApprove: _handleApprove,
          onFinalize: _handleFinalize,
        ),
      ),
    ).then((_) => _loadStockCheckNotes());
  }

  Future<void> _handleSubmitNewStockCheck(StockCheckNoteRequest request) async {
    try {
      await widget.apiService.createStockCheckNote(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock check note created successfully')),
      );
      _loadStockCheckNotes();
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

// UI Components (updated to use API data)
class StockCheckListScreen extends StatelessWidget {
  final String? warehouseCode;
  final List<StockCheckNote> stockCheckNotes;
  final Function() onRefresh;
  final Function(String noteId) onApprove;
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
            onApprove: note.status.toLowerCase() == 'pending'
                ? () => onApprove(note.stockCheckNoteId)
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
        title: Text('Stock Check: ${stockCheckNote.warehouse.warehouseName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(stockCheckNote.date))}'),
            Text('Status: ${stockCheckNote.status}'),
            Text('Products: ${stockCheckNote.stockCheckProducts.length}'),
            if (stockCheckNote.description.isNotEmpty)
              Text('Note: ${stockCheckNote.description}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: stockCheckNote.status.toLowerCase() == 'pending' && onApprove != null
            ? ElevatedButton(
          onPressed: onApprove,
          child: const Text('Approve'),
        )
            : _getStatusIcon(stockCheckNote.status),
        onTap: onTap,
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'accepted':
        return const Icon(Icons.check_circle_outline, color: Colors.blue);
      case 'finished':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}

class StockCheckDetailScreen extends StatelessWidget {
  final StockCheckNote stockCheckNote;
  final Function(String noteId) onApprove;
  final Function(String noteId, bool isFinished) onFinalize;

  const StockCheckDetailScreen({
    Key? key,
    required this.stockCheckNote,
    required this.onApprove,
    required this.onFinalize,
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
                    Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(stockCheckNote.date))}'),
                    const SizedBox(height: 8),
                    Text('Warehouse: ${stockCheckNote.warehouse.warehouseName}'),
                    const SizedBox(height: 8),
                    Text('Checker: ${stockCheckNote.checker.fullName}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Status: '),
                        _buildStatusChip(stockCheckNote.status),
                      ],
                    ),
                    if (stockCheckNote.description.isNotEmpty) ...[
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
                                product.product.productName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('Product Code: ${product.product.productCode}'),
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
            if (stockCheckNote.status.toLowerCase() == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onApprove(stockCheckNote.stockCheckNoteId);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            if (stockCheckNote.status.toLowerCase() == 'accepted')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onFinalize(stockCheckNote.stockCheckNoteId, true);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Finalize'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      onFinalize(stockCheckNote.stockCheckNoteId, false);
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'finished':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}

class StockCheckCreateScreen extends StatefulWidget {
  final String? warehouseCode;
  final List<Warehouse> availableWarehouses;
  final List<Product> availableProducts;
  final Function(StockCheckNoteRequest note) onSubmit;
  final StockCheckApiService apiService;

  const StockCheckCreateScreen({
    Key? key,
    this.warehouseCode,
    required this.availableWarehouses,
    required this.availableProducts,
    required this.onSubmit,
    required this.apiService,
  }) : super(key: key);

  @override
  State<StockCheckCreateScreen> createState() => _StockCheckCreateScreenState();
}

class _StockCheckCreateScreenState extends State<StockCheckCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedWarehouseCode = '';
  List<StockCheckProductRequest> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.warehouseCode != null) {
      _selectedWarehouseCode = widget.warehouseCode!;
    } else if (widget.availableWarehouses.isNotEmpty) {
      _selectedWarehouseCode = widget.availableWarehouses.first.warehouseCode;
    }

    // Add one empty product by default
    if (widget.availableProducts.isNotEmpty) {
      _products.add(StockCheckProductRequest(
        productCode: widget.availableProducts.first.productCode,
        actualQuantity: 0,
      ));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      if (widget.availableProducts.isNotEmpty) {
        _products.add(StockCheckProductRequest(
          productCode: widget.availableProducts.first.productCode,
          actualQuantity: 0,
        ));
      }
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
        final stockCheckNoteRequest = StockCheckNoteRequest(
          warehouseCode: _selectedWarehouseCode,
          description: _descriptionController.text,
          stockCheckProducts: _products,
        );

        widget.onSubmit(stockCheckNoteRequest);

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
                value: _selectedWarehouseCode.isNotEmpty ? _selectedWarehouseCode : null,
                items: widget.availableWarehouses
                    .map((warehouse) => DropdownMenuItem<String>(
                  value: warehouse.warehouseCode,
                  child: Text('${warehouse.warehouseName} (${warehouse.warehouseCode})'),
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
                value: product.productCode,
                child: Text('${product.productName} (${product.productCode})'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _products[index] = StockCheckProductRequest(
                    productCode: value!,
                    actualQuantity: product.actualQuantity,
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
                  _products[index] = StockCheckProductRequest(
                    productCode: product.productCode,
                    actualQuantity: int.tryParse(value) ?? 0,
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
  final StockCheckApiService apiService;

  const StockCheckScreen({
    Key? key,
    required this.apiService
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StockCheckMainScreen(apiService: apiService);
  }
}