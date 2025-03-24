import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swd_mobile/components.dart';
import 'package:swd_mobile/services/auth_service.dart';

// Import the stock transaction service
import 'package:swd_mobile/services/transaction_service.dart';

class ImportTransactionScreen extends StatefulWidget {
  const ImportTransactionScreen({Key? key}) : super(key: key);

  @override
  _ImportTransactionScreenState createState() => _ImportTransactionScreenState();
}

class _ImportTransactionScreenState extends State<ImportTransactionScreen> {
  // Fixed transaction type to IMPORT
  final TransactionType _transactionType = TransactionType.IMPORT;

  String? _destinationWarehouseCode;

  final List<TransactionItemRequest> _items = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Transaction response for showing results
  StockExchangeResponse? _transactionResponse;

  // Controllers for new items
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteItemCodeController = TextEditingController();

  // Service instance
  late StockTransactionService _service;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    // Get token from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Create service with base URL from your environment
    _service = StockTransactionService(
      baseUrl: 'https://app-250312143530.azurewebsites.net/api',
      authService: AuthService(baseUrl: 'https://app-250312143530.azurewebsites.net/api'),
    );

    // Set auth token from shared preferences
    if (token != null) {
      _service.authService.getToken();
    }
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _quantityController.dispose();
    _noteItemCodeController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_productCodeController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product code and quantity are required')),
      );
      return;
    }

    setState(() {
      _items.add(
        TransactionItemRequest(
          productCode: _productCodeController.text,
          quantity: int.parse(_quantityController.text),
          noteItemCode: _noteItemCodeController.text.isEmpty
              ? null
              : _noteItemCodeController.text,
        ),
      );

      // Clear fields
      _productCodeController.clear();
      _quantityController.clear();
      _noteItemCodeController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _createImportTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item to the transaction')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _transactionResponse = null;
    });

    try {
      final request = StockExchangeRequest(
        transactionType: _transactionType,
        sourceWarehouseCode: null,
        destinationWarehouseCode: _destinationWarehouseCode?.isNotEmpty == true
            ? _destinationWarehouseCode
            : null,
        items: _items,
      );

      // Attempt to create the transaction
      final response = await _service.createTransaction(request);

      setState(() {
        _transactionResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      // Even if there's an error, we still set loading to false
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Import Stock',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: buildNavigationDrawer(context, {}, setState),
      body: _buildImportTransactionContent(),
    );
  }

  Widget _buildImportTransactionContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Display fixed transaction type
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Transaction Type',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_transactionType.value),
                    ),
                    const SizedBox(height: 12),

                    // Destination Warehouse (optional)
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Destination Warehouse Code',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _destinationWarehouseCode = value.isEmpty ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Code
                    TextFormField(
                      controller: _productCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Product Code *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Note Item Code (optional)
                    TextFormField(
                      controller: _noteItemCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Note Item Code (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_items.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Products to Import',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            title: Text('Product: ${item.productCode}'),
                            subtitle: Text('Quantity: ${item.quantity}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createImportTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('CREATE IMPORT TRANSACTION'),
              ),
            ),

            const SizedBox(height: 16),

            if (_transactionResponse != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Import Transaction Created',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Exchange Note ID: ${_transactionResponse!.transactionId}'),
                      Text('Transaction Type: ${_transactionResponse!.transactionType.value}'),
                      Text('Status: ${_transactionResponse!.status.value}'),
                      Text('Created By: ${_transactionResponse!.createdBy}'),

                      if (_transactionResponse!.items != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Imported Products:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...(_transactionResponse!.items ?? []).map((item) => Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                          child: Text(
                            '${item.productName} (${item.productCode}) - Qty: ${item.quantity}',
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}