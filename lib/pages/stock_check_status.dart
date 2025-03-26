import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:swd_mobile/services/stock_check.dart';

class StockCheckStatusScreen extends StatefulWidget {
  @override
  _StockCheckStatusScreenState createState() => _StockCheckStatusScreenState();
}

class _StockCheckStatusScreenState extends State<StockCheckStatusScreen> {
  final StockCheckApi _stockCheckApi = StockCheckApi();
  List<StockCheckNote> _stockCheckNotes = [];
  List<StockCheckNote> _filteredNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<WarehouseInfo> _warehouses = [];
  String? _selectedWarehouse;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStockCheckNotes();
    _loadWarehouses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouses() async {
    // You would need to implement a method to fetch warehouses from your API
    // This is a placeholder - you'll need to create a method in your API class to get warehouses
    // For now, we'll extract unique warehouses from the stock check notes
    await _loadStockCheckNotes();
    final Set<String> warehouseCodes = {};
    final List<WarehouseInfo> warehouses = [];

    for (var note in _stockCheckNotes) {
      if (!warehouseCodes.contains(note.warehouseCode)) {
        warehouseCodes.add(note.warehouseCode);
        warehouses.add(WarehouseInfo(
          warehouseId: '', // You might not have this information
          warehouseCode: note.warehouseCode,
          warehouseName: note.warehouseName,
        ));
      }
    }

    setState(() {
      _warehouses = warehouses;
    });
  }

  Future<void> _loadStockCheckNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _stockCheckApi.getAllStockCheckNotes();
      setState(() {
        _stockCheckNotes = notes;
        _filterNotes();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load stock check notes: $e');
    }
  }

  void _filterNotes() {
    if (_searchQuery.isEmpty && _selectedWarehouse == null) {
      _filteredNotes = List.from(_stockCheckNotes);
    } else {
      _filteredNotes = _stockCheckNotes.where((note) {
        bool matchesSearch = _searchQuery.isEmpty ||
            note.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.warehouseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.warehouseCode.toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesWarehouse = _selectedWarehouse == null ||
            note.warehouseCode == _selectedWarehouse;

        return matchesSearch && matchesWarehouse;
      }).toList();
    }
  }

  Future<void> _approveStockCheck(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _stockCheckApi.approveStockCheck(id);
      _showSuccessSnackBar('Stock check approved successfully');
      await _loadStockCheckNotes();
    } catch (e) {
      _showErrorSnackBar('You are not authorize to do this');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _finalizeStockCheck(String id, bool isFinished) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _stockCheckApi.finalizeStockCheck(id, isFinished);
      _showSuccessSnackBar('Stock check finalized successfully');
      await _loadStockCheckNotes();
    } catch (e) {
      _showErrorSnackBar('Failed to finalize stock check: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: Text(
            'Stock Check Status',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStockCheckNotes,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredNotes.isEmpty
                ? Center(child: Text('No stock check notes found'))
                : ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                return _buildStockCheckCard(_filteredNotes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by description or warehouse',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _filterNotes();
                  });
                },
              )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filterNotes();
              });
            },
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by Warehouse',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            value: _selectedWarehouse,
            onChanged: (newValue) {
              setState(() {
                _selectedWarehouse = newValue;
                _filterNotes();
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('All Warehouses'),
              ),
              ..._warehouses.map((warehouse) {
                return DropdownMenuItem<String>(
                  value: warehouse.warehouseCode,
                  child: Text('${warehouse.warehouseName} (${warehouse.warehouseCode})'),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCheckCard(StockCheckNote note) {
    // Define different colors based on status
    Color statusColor;
    switch (note.stockCheckStatus.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        break;
      case 'finished':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          'Stock Check #${note.stockCheckNoteId}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Warehouse: ${note.warehouseName} (${note.warehouseCode})'),
            Text('Date: ${_formatDate(note.date)}'),
            Row(
              children: [
                Text('Status: '),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    note.stockCheckStatus,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.description.isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(note.description),
                  SizedBox(height: 8),
                ],
                Text(
                  'Checker: ${note.checkerName}',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 8),
                Text(
                  'Products (${note.stockCheckProducts.length}):',
                ),
                SizedBox(height: 4),
                _buildProductsTable(note.stockCheckProducts),
                SizedBox(height: 16),
                _buildActionButtons(note),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(List<StockCheckProduct> products) {
    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Expected')),
            DataColumn(label: Text('Actual')),
            DataColumn(label: Text('Difference')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(Text(product.productName ?? product.productCode ?? 'N/A')),
                DataCell(Text('${product.expectedQuantity}')),
                DataCell(Text('${product.actualQuantity}')),
                DataCell(
                  Text(
                    '${product.difference}',
                    style: TextStyle(
                      color: product.difference < 0
                          ? Colors.red
                          : product.difference > 0
                          ? Colors.green
                          : Colors.black,
                      fontWeight: product.difference != 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionButtons(StockCheckNote note) {
    final status = note.stockCheckStatus.toLowerCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Approve button - show only for pending notes
        if (status == 'pending')
          ElevatedButton.icon(
            icon: Icon(Icons.check),
            label: Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showConfirmationDialog(
              title: 'Approve Stock Check',
              content: 'Are you sure you want to approve this stock check? You can finalize it after approval.',
              onConfirm: () => _approveStockCheck(note.stockCheckNoteId),
            ),
          ),

        // Finalize button - show only for approved notes
        if (status == 'accepted')
          ElevatedButton.icon(
            icon: Icon(Icons.done_all),
            label: Text('Finalize'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showConfirmationDialog(
              title: 'Finalize Stock Check',
              content: 'Are you sure you want to finalize this stock check?',
              onConfirm: () => _finalizeStockCheck(note.stockCheckNoteId, true),
            ),
          ),

        if (status == 'accepted')
          ElevatedButton.icon(
            icon: Icon(Icons.cancel),
            label: Text('Rejected'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _showConfirmationDialog(
              title: 'Reject Stock Check',
              content: 'Are you sure you want to reject this stock check?',
              onConfirm: () => _finalizeStockCheck(note.stockCheckNoteId, false),
            ),
          ),
      ],
    );
  }

  Future<void> _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(String dateString) {
    // You can implement a date formatting method based on your API's date format
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }
}

// Helper widget to display the stock check details
class StockCheckDetailScreen extends StatelessWidget {
  final StockCheckNote note;

  const StockCheckDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Check Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Check #${note.stockCheckNoteId}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(),
                    _buildInfoRow('Date', note.date),
                    _buildInfoRow('Warehouse', '${note.warehouseName} (${note.warehouseCode})'),
                    _buildInfoRow('Status', note.stockCheckStatus),
                    _buildInfoRow('Checker', note.checkerName),
                    if (note.description.isNotEmpty)
                      _buildInfoRow('Description', note.description),
                  ],
                ),
              ),
            ),
            Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...note.stockCheckProducts.map((product) => _buildProductCard(product)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildProductCard(StockCheckProduct product) {
    final bool hasDifference = product.difference != 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.productName ?? product.productCode ?? 'Unknown Product',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityColumn('Expected', product.expectedQuantity),
                _buildQuantityColumn('Actual', product.actualQuantity),
                _buildQuantityColumn(
                  'Difference',
                  product.difference,
                  color: hasDifference
                      ? (product.difference < 0 ? Colors.red : Colors.green)
                      : null,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildQuantityColumn('Last Count', product.lastQuantity),
                _buildQuantityColumn('Total Import', product.totalImportQuantity),
                _buildQuantityColumn('Total Export', product.totalExportQuantity),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityColumn(String label, int value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}