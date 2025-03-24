import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swd_mobile/components.dart';
import 'package:swd_mobile/services/stock_check.dart';

class StockCheckListScreen extends StatefulWidget {
  @override
  _StockCheckListScreenState createState() => _StockCheckListScreenState();
}

class _StockCheckListScreenState extends State<StockCheckListScreen> {
  final StockCheckApi api = StockCheckApi();
  late Future<List<StockCheckNote>> stockChecks;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    stockChecks = api.getAllStockCheckNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchStockChecks() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _isSearching = _searchQuery.isNotEmpty;
      if (_isSearching) {
        stockChecks = api.getStockCheckNotesByWarehouse(_searchQuery);
      } else {
        stockChecks = api.getAllStockCheckNotes();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      stockChecks = api.getAllStockCheckNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildNavigationDrawer(context, {}, setState),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by warehouse code',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        onSubmitted: (_) => _searchStockChecks(),
                      ),
                    ),
                    _isSearching
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                        : IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _searchStockChecks,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StockCheckNote>>(
              future: stockChecks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final notes = snapshot.data ?? [];

                if (notes.isEmpty && _isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No stock checks found for warehouse code "$_searchQuery"',
                          style: TextStyle(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else if (notes.isEmpty) {
                  return Center(
                    child: Text('No stock checks available'),
                  );
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(note.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${note.stockCheckNoteId}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Warehouse: ${note.warehouseCode} - ${note.warehouseName}'),
                            Text('Checker: ${note.checkerName}'),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(note.stockCheckStatus),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                note.stockCheckStatus,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StockCheckDetailsScreen(note: note),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateStockCheckScreen()),
          ).then((_) {
            // Refresh the list when returning from create screen
            setState(() {
              if (_isSearching) {
                stockChecks = api.getStockCheckNotesByWarehouse(_searchQuery);
              } else {
                stockChecks = api.getAllStockCheckNotes();
              }
            });
          });
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'finished':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}

class StockCheckDetailsScreen extends StatelessWidget {
  final StockCheckNote note;
  StockCheckDetailsScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Stock Check Details',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            _buildInfoCard([
              _buildInfoRow('ID', note.stockCheckNoteId),
              _buildInfoRow('Description', note.description),
              _buildInfoRow('Date', note.date),
              _buildInfoRow('Status', note.stockCheckStatus),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Warehouse Information'),
            _buildInfoCard([
              _buildInfoRow('Warehouse Code', note.warehouseCode),
              _buildInfoRow('Warehouse Name', note.warehouseName),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Checker Information'),
            _buildInfoCard([
              _buildInfoRow('Name', note.checkerName),
            ]),

            SizedBox(height: 16),
            _buildSectionTitle('Products'),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: note.stockCheckProducts.length,
              itemBuilder: (context, index) {
                final product = note.stockCheckProducts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName ?? 'Unknown Product',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Product Code', product.productCode ?? 'N/A'),
                        _buildInfoRow('Actual Quantity', product.actualQuantity.toString()),
                        _buildInfoRow('Expected Quantity', product.expectedQuantity.toString()),
                        _buildInfoRow('Last Quantity', product.lastQuantity.toString()),
                        _buildInfoRow('Total Import', product.totalImportQuantity.toString()),
                        _buildInfoRow('Total Export', product.totalExportQuantity.toString()),
                        _buildInfoRow('Difference', product.difference.toString()),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontFamily: 'Roboto',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateStockCheckScreen extends StatefulWidget {
  @override
  _CreateStockCheckScreenState createState() => _CreateStockCheckScreenState();
}

class _CreateStockCheckScreenState extends State<CreateStockCheckScreen> {
  final _warehouseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final StockCheckApi api = StockCheckApi();
  final List<StockCheckProduct> _selectedProducts = [];

  void _createStockCheck() async {
    try {
      await api.createStockCheckNote(
        warehouseCode: _warehouseController.text,
        description: _descriptionController.text,
        stockCheckProducts: _selectedProducts,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock check created successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating stock check: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Create Stock Check',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueAccent
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _warehouseController,
              decoration: InputDecoration(labelText: 'Warehouse Code'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = _selectedProducts[index];
                  return ListTile(
                    title: Text(product.productCode ?? 'No code'),
                    subtitle: Text('Actual Quantity: ${product.actualQuantity}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _selectedProducts.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddProductDialog(context);
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createStockCheck,
              child: Text('Create Stock Check'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final _productCodeController = TextEditingController();
    final _quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productCodeController,
                decoration: InputDecoration(labelText: 'Product Code'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Actual Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final productCode = _productCodeController.text;
                final quantity = int.tryParse(_quantityController.text) ?? 0;

                if (productCode.isNotEmpty && quantity > 0) {
                  setState(() {
                    _selectedProducts.add(
                      StockCheckProduct(
                        productCode: productCode,
                        productName: null,
                        actualQuantity: quantity,
                        expectedQuantity: 0,
                        lastQuantity: 0,
                        totalImportQuantity: 0,
                        totalExportQuantity: 0,
                        difference: 0,
                      ),
                    );
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter valid product information')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}