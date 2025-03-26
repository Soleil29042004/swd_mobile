import 'package:flutter/material.dart';
import 'package:swd_mobile/services/transaction_service.dart';
import 'package:swd_mobile/services/auth_service.dart';

class TransactionManagementScreen extends StatefulWidget {
  const TransactionManagementScreen({Key? key}) : super(key: key);

  @override
  _TransactionManagementScreenState createState() => _TransactionManagementScreenState();
}

class _TransactionManagementScreenState extends State<TransactionManagementScreen> {
  late StockTransactionService _transactionService;
  final TextEditingController _searchController = TextEditingController();

  List<StockExchangeResponse> _allTransactions = [];
  List<StockExchangeResponse> _filteredTransactions = [];

  bool _isLoading = true;
  bool _showOnlyPending = false;
  bool _isSearching = false;
  String? _errorMessage;

  StockExchangeResponse? _selectedTransaction;
  bool _isProcessingAction = false;

  // Responsive design variables
  bool _isDetailViewOpen = false;

  @override
  void initState() {
    super.initState();
    _transactionService = StockTransactionService(
      baseUrl: 'https://app-250312143530.azurewebsites.net/api',
      authService: AuthService(baseUrl: 'https://app-250312143530.azurewebsites.net/api'),
    );
    _loadAllTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedTransaction = null;
      _isDetailViewOpen = false;
    });

    try {
      final transactions = await _transactionService.getAllTransactions();
      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'You are not authorize for this page';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPendingTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedTransaction = null;
      _isDetailViewOpen = false;
    });

    try {
      final transactions = await _transactionService.getPendingTransactions();
      setState(() {
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pending transactions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchTransactionById(String id) async {
    if (id.isEmpty) {
      setState(() {
        _filteredTransactions = _showOnlyPending
            ? _allTransactions.where((t) => t.status == StockExchangeStatus.pending).toList()
            : _allTransactions;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _selectedTransaction = null;
      _isDetailViewOpen = false;
    });

    try {
      final transaction = await _transactionService.getTransactionById(id);
      setState(() {
        _filteredTransactions = [transaction];
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Transaction not found: $e';
        _filteredTransactions = [];
        _isSearching = false;
      });
    }
  }

  void _filterTransactions() {
    if (_showOnlyPending) {
      setState(() {
        _filteredTransactions = _allTransactions
            .where((transaction) => transaction.status == StockExchangeStatus.pending)
            .toList();
      });
    } else {
      setState(() {
        _filteredTransactions = _allTransactions;
      });
    }
  }

  Future<void> _approveTransaction() async {
    if (_selectedTransaction == null) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final updatedTransaction = await _transactionService.approveTransaction(
        _selectedTransaction!.transactionId,
      );

      _updateTransactionInLists(updatedTransaction);

      setState(() {
        _selectedTransaction = updatedTransaction;
        _isProcessingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction approved successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to approve transaction: $e';
        _isProcessingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve transaction: $e')),
      );
    }
  }

  Future<void> _finalizeTransaction({required bool isFinished}) async {
    if (_selectedTransaction == null) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final updatedTransaction = await _transactionService.finalizeTransaction(
        _selectedTransaction!.transactionId,
        isFinished: isFinished,
      );

      _updateTransactionInLists(updatedTransaction);

      setState(() {
        _selectedTransaction = updatedTransaction;
        _isProcessingAction = false;
      });

      final message = isFinished
          ? 'Transaction marked as finished'
          : 'Transaction rejected';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    catch (e) {
      setState(() {
        _errorMessage = 'Failed to update transaction: $e';
        _isProcessingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update transaction: $e')),
      );
    }
  }

  Future<void> _cancelTransaction() async {
    if (_selectedTransaction == null) return;

    setState(() {
      _isProcessingAction = true;
    });

    try {
      final updatedTransaction = await _transactionService.cancelTransaction(
        _selectedTransaction!.transactionId,
      );

      _updateTransactionInLists(updatedTransaction);

      setState(() {
        _selectedTransaction = updatedTransaction;
        _isProcessingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction cancelled successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to cancel transaction: $e';
        _isProcessingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel transaction: $e')),
      );
    }
  }

  void _updateTransactionInLists(StockExchangeResponse updatedTransaction) {
    setState(() {
      // Update in all transactions list
      final allIndex = _allTransactions.indexWhere(
              (t) => t.transactionId == updatedTransaction.transactionId);
      if (allIndex != -1) {
        _allTransactions[allIndex] = updatedTransaction;
      }

      // Update in filtered transactions list
      final filteredIndex = _filteredTransactions.indexWhere(
              (t) => t.transactionId == updatedTransaction.transactionId);
      if (filteredIndex != -1) {
        _filteredTransactions[filteredIndex] = updatedTransaction;
      }
    });
  }

  String _getStatusText(StockExchangeStatus status) {
    switch (status) {
      case StockExchangeStatus.pending:
        return 'Pending';
      case StockExchangeStatus.accepted:
        return 'Accepted';
      case StockExchangeStatus.rejected:
        return 'Rejected';
      case StockExchangeStatus.finished:
        return 'Finished';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(StockExchangeStatus status) {
    switch (status) {
      case StockExchangeStatus.pending:
        return Colors.orange;
      case StockExchangeStatus.accepted:
        return Colors.blue;
      case StockExchangeStatus.rejected:
        return Colors.red;
      case StockExchangeStatus.finished:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return Center(
        child: _errorMessage != null
            ? Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        )
            : const Text('No transactions found'),
      );
    }

    return ListView.builder(
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        final isSelected = _selectedTransaction?.transactionId == transaction.transactionId;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            title: Text(
              'Transaction #${transaction.transactionId}',
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${transaction.transactionType == TransactionType.IMPORT ? 'Import' : 'Export'}',
                ),
                Text(
                  'Created by: ${transaction.createdBy}',
                ),
              ],
            ),
            trailing: Chip(
              label: Text(
                _getStatusText(transaction.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: _getStatusColor(transaction.status),
            ),
            onTap: () {
              setState(() {
                _selectedTransaction = transaction;
                // On mobile, open the detail view when a transaction is selected
                if (MediaQuery.of(context).size.width < 768) {
                  _isDetailViewOpen = true;
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionDetails() {
    if (_selectedTransaction == null) {
      return const Center(
        child: Text('Select a transaction to view details'),
      );
    }

    final transaction = _selectedTransaction!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Transaction #${transaction.transactionId}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Add back button for mobile view
              if (MediaQuery.of(context).size.width < 768)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isDetailViewOpen = false;
                    });
                  },
                ),
              Chip(
                label: Text(
                  _getStatusText(transaction.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getStatusColor(transaction.status),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction details
          _buildDetailItem('Type',
              transaction.transactionType == TransactionType.IMPORT ? 'Import' : 'Export'),

          if (transaction.sourceWarehouseCode != null)
            _buildDetailItem('Source Warehouse', transaction.sourceWarehouseCode!),

          if (transaction.destinationWarehouseCode != null)
            _buildDetailItem('Destination Warehouse', transaction.destinationWarehouseCode!),

          _buildDetailItem('Created By', transaction.createdBy),

          if (transaction.approvedBy != null)
            _buildDetailItem('Approved By', transaction.approvedBy!),

          const SizedBox(height: 24),

          // Items section
          const Text(
            'Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (transaction.items == null || transaction.items!.isEmpty)
            const Text('No items in this transaction')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transaction.items?.length ?? 0,
              itemBuilder: (context, index) {
                final item = transaction.items![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Product Code: ${item.productCode}'),
                        Text('Item Code: ${item.noteItemCode}'),
                        Text('Quantity: ${item.quantity}'),
                        Text('Warehouse: ${item.warehouseCode}'),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 16),

          // Action buttons based on current status
          _buildActionButtons(transaction.status),

          // Add some bottom padding for mobile view
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: MediaQuery.of(context).size.width > 500
          ? Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(StockExchangeStatus status) {
    if (_isProcessingAction) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (status == StockExchangeStatus.pending) {
      return ElevatedButton(
        onPressed: _approveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size.fromHeight(50),
        ),
        child: const Text(
          'Approve Transaction',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else if (status == StockExchangeStatus.accepted) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () => _finalizeTransaction(isFinished: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              'Mark as Finished',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _cancelTransaction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text(
              'Reject Transaction',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // No actions for finished or rejected transactions
    return const SizedBox.shrink();
  }

  // Build a responsive search section that adapts to screen size
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: MediaQuery.of(context).size.width > 600
          ? Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Exchange Note ID',
              hintText: 'Enter ID to search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchTransactionById('');
                },
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => _searchTransactionById(value),
          ),

          const SizedBox(height: 8),

          // Filter options
          Row(
            children: [
              // Pending only filter
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Show only pending'),
                  value: _showOnlyPending,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyPending = value ?? false;
                      if (_showOnlyPending) {
                        _loadPendingTransactions();
                      } else {
                        _filteredTransactions = _allTransactions;
                      }
                    });
                  },
                ),
              ),

              // Apply search button
              ElevatedButton(
                onPressed: () => _searchTransactionById(_searchController.text),
                child: _isSearching
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
                    : const Text('Search'),
              ),
            ],
          ),
        ],
      )
          : Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by Exchange Note ID',
              hintText: 'Enter ID to search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchTransactionById('');
                },
              )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => _searchTransactionById(value),
          ),

          const SizedBox(height: 8),

          // Pending only filter
          CheckboxListTile(
            title: const Text('Show only pending'),
            value: _showOnlyPending,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _showOnlyPending = value ?? false;
                if (_showOnlyPending) {
                  _loadPendingTransactions();
                } else {
                  _filteredTransactions = _allTransactions;
                }
              });
            },
          ),

          const SizedBox(height: 8),

          // Apply search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _searchTransactionById(_searchController.text),
              child: _isSearching
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              )
                  : const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to determine screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Transactions Management',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search and filter section
          _buildSearchSection(),

          // Error message (if any)
          if (_errorMessage != null && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          // Main content - responsive layout based on screen size
          Expanded(
            child: isDesktop
            // Desktop layout: Side-by-side using Row
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side - Transaction list
                Expanded(
                  flex: 2,
                  child: _buildTransactionList(),
                ),

                // Divider
                const VerticalDivider(width: 1),

                // Right side - Transaction details
                Expanded(
                  flex: 3,
                  child: _buildTransactionDetails(),
                ),
              ],
            )
            // Mobile layout: Stack with conditional visibility
                : _isDetailViewOpen && _selectedTransaction != null
                ? _buildTransactionDetails()
                : _buildTransactionList(),
          ),
        ],
      ),
    );
  }
}