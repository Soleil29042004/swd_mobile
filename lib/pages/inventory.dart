import 'package:flutter/material.dart';
import 'package:swd_mobile/services/location_service.dart'; // Import the location service
import 'package:swd_mobile/components.dart'; // Assuming you have a components file for shared UI elements
import 'package:swd_mobile/pages/home.dart';
import 'package:swd_mobile/pages/profile.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _currentIndex = 1;

  bool isLoading = false;
  String errorMessage = '';
  final TextEditingController _productCodeController = TextEditingController();
  StockResponse? selectedStock;
  bool hasSearched = false;

  // Create an instance of ProductLocationsService
  final ProductLocationsService _productLocationsService = ProductLocationsService();

  // Fetch stock by product code from API
  void getStockByProductCode(String productCode) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final stock = await _productLocationsService.fetchProductLocations(productCode);

      setState(() {
        isLoading = false;
        selectedStock = stock;
        hasSearched = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        selectedStock = null;
        hasSearched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildNavigationDrawer(context, {}, setState),
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
      bottomNavigationBar: buildBottomNavigationBar(
        context,
        _currentIndex,
            (index) {
          setState(() {
            _currentIndex = index;
          });

          // Handle navigation based on index
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
          }
          // Note: index 3 (logout) is already handled in the buildBottomNavigationBar function
        },
      ),
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
              hintText: 'Enter product code (e.g. PR001)',
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
    return Center(
      child: Text(
        'Enter a product code to search for stock locations',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
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
          _buildWarehousesList(isSmallScreen),
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
              child: Text('Search Another Product'),
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
              'Product Details',
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
                      Text('Product Code: ${selectedStock!.productCode}'),
                      SizedBox(height: 8),
                      Text('Product Name: ${selectedStock!.productName}'),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Total Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${selectedStock!.totalQuantity}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: selectedStock!.totalQuantity > 0 ? Colors.green : Colors.red,
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

  Widget _buildWarehousesList(bool isSmallScreen) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Warehouse Locations',
              style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: selectedStock!.warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = selectedStock!.warehouses[index];
                return ListTile(
                  title: Text(warehouse.warehouseName),
                  subtitle: Text('Warehouse Code: ${warehouse.warehouseCode}'),
                  trailing: Text(
                    'Quantity: ${warehouse.totalQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: warehouse.totalQuantity > 0 ? Colors.green : Colors.red,
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

  @override
  void dispose() {
    _productCodeController.dispose();
    super.dispose();
  }
}