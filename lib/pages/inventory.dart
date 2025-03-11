import 'package:flutter/material.dart';
import 'package:swd_mobile/components.dart';

// Data models aligned with backend StockResponse
class StockResponse {
  final String stockCode;
  final String productCode;
  final String productName;
  final int quantity;

  StockResponse({
    required this.stockCode,
    required this.productCode,
    required this.productName,
    required this.quantity,
  });
}

class InvetoryScreen extends StatefulWidget {
  @override
  _InvetoryScreenState createState() => _InvetoryScreenState();
}

class _InvetoryScreenState extends State<InvetoryScreen> {
  int _currentIndex = 1;

  Map<String, bool> _drawerSectionState = {
    "Home": false,
    "Xuất-nhập ngoại": false,
    "Xuất-nhập nội": false,
    "Quản lý hàng hóa": false,
  };

  bool isLoading = false;
  String errorMessage = '';
  final TextEditingController _productCodeController = TextEditingController();
  List<StockResponse> allStocks = [];
  StockResponse? selectedStock;
  bool hasSearched = false;

  // Mock data to simulate backend response
  final List<StockResponse> mockStocks = [
    StockResponse(
      stockCode: "STK-001",
      productCode: "P-001",
      productName: "Product One",
      quantity: 98,
    ),
    StockResponse(
      stockCode: "STK-002",
      productCode: "P-002",
      productName: "Product Two",
      quantity: 52,
    ),
    StockResponse(
      stockCode: "STK-003",
      productCode: "P-003",
      productName: "Product Three",
      quantity: 75,
    ),
    StockResponse(
      stockCode: "STK-004",
      productCode: "P-004",
      productName: "Product Four",
      quantity: 115,
    ),
    StockResponse(
      stockCode: "STK-005",
      productCode: "P-005",
      productName: "Product Five",
      quantity: 80,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with mock data for now
    allStocks = mockStocks;
  }

  // Simulate fetching stock by product code
  void getStockByProductCode(String productCode) {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // Simulate network delay
    Future.delayed(Duration(seconds: 1), () {
      final stock = mockStocks.firstWhere(
            (s) => s.productCode == productCode,
        orElse: () => StockResponse(
            stockCode: "",
            productCode: "",
            productName: "",
            quantity: 0
        ),
      );

      setState(() {
        isLoading = false;
        if (stock.stockCode.isNotEmpty) {
          selectedStock = stock;
        } else {
          errorMessage = 'No stock found for product code: $productCode';
          selectedStock = null;
        }
        hasSearched = true;
      });
    });
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: buildAppBar(context), // Use the function from components.dart
      drawer: buildNavigationDrawer(context, _drawerSectionState, setState), // Use the drawer function
      body: Column(
        children: [
          _buildSearchBar(isSmallScreen),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                : !hasSearched
                ? _buildAllStocksContent(isSmallScreen)
                : selectedStock == null
                ? Center(child: Text('No stock data available for this product code'))
                : _buildStockDetailContent(isSmallScreen),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(_currentIndex, (index) {
          switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case 3:
            handleLogout(context);
            break;
          }
        }
      )
    );
  }

  Widget _buildSearchBar(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      child: isSmallScreen
          ? Column(
        children: [
          TextField(
            controller: _productCodeController,
            decoration: InputDecoration(
              labelText: 'Product Code',
              hintText: 'Enter product code (e.g. P-001)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_productCodeController.text.isNotEmpty) {
                  getStockByProductCode(_productCodeController.text);
                }
              },
              child: Text('Search'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: TextField(
              controller: _productCodeController,
              decoration: InputDecoration(
                labelText: 'Product Code',
                hintText: 'Enter product code (e.g. P-001)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              if (_productCodeController.text.isNotEmpty) {
                getStockByProductCode(_productCodeController.text);
              }
            },
            child: Text('Search'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStocksContent(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
          child: Text(
            'All Stocks',
            style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: allStocks.isEmpty
              ? Center(child: Text('No stocks available'))
              : isSmallScreen
              ? _buildStocksList()
              : _buildStocksTable(),
        ),
      ],
    );
  }

  // Table view for larger screens
  Widget _buildStocksTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Stock Code')),
            DataColumn(label: Text('Product Code')),
            DataColumn(label: Text('Product Name')),
            DataColumn(label: Text('Quantity'), numeric: true),
          ],
          rows: allStocks.map((stock) {
            return DataRow(
              cells: [
                DataCell(Text(stock.stockCode)),
                DataCell(Text(stock.productCode)),
                DataCell(Text(stock.productName)),
                DataCell(Text('${stock.quantity}')),
              ],
              onSelectChanged: (selected) {
                if (selected == true) {
                  setState(() {
                    selectedStock = stock;
                    hasSearched = true;
                    _productCodeController.text = stock.productCode;
                  });
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Card list view for smaller screens
  Widget _buildStocksList() {
    return ListView.builder(
      itemCount: allStocks.length,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemBuilder: (context, index) {
        final stock = allStocks[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              stock.productName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${stock.productCode} | Stock: ${stock.stockCode}'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: stock.quantity > 0 ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stock.quantity}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              setState(() {
                selectedStock = stock;
                hasSearched = true;
                _productCodeController.text = stock.productCode;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildStockDetailContent(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 16),
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  hasSearched = false;
                  selectedStock = null;
                  _productCodeController.clear();
                });
              },
              child: Text('Back to All Stocks'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isSmallScreen) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Details',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stock Code: ${selectedStock!.stockCode}'),
                      SizedBox(height: 8),
                      Text('Product Code: ${selectedStock!.productCode}'),
                      SizedBox(height: 8),
                      Text('Product Name: ${selectedStock!.productName}'),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${selectedStock!.quantity}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: selectedStock!.quantity > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}