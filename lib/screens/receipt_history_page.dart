import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ReceiptHistoryPage extends StatefulWidget {
  const ReceiptHistoryPage({super.key});

  @override
  State<ReceiptHistoryPage> createState() => _ReceiptHistoryPageState();
}

class _ReceiptHistoryPageState extends State<ReceiptHistoryPage> {
  final ReceiptUploadService _receiptService = ReceiptUploadService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _filterType = 'all'; // 'all', 'membership', 'program_fee'

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receipt History')),
        body: const Center(child: Text('Please log in to view receipts')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipts'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterButton('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterButton('Membership', 'membership'),
                const SizedBox(width: 8),
                _buildFilterButton('Program Fee', 'program_fee'),
              ],
            ),
          ),
          // Receipts list
          Expanded(
            child: _buildReceiptsList(user.uid),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String type) {
    final isSelected = _filterType == type;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _filterType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildReceiptsList(String userId) {
    final stream = _filterType == 'all'
        ? _receiptService.getUserReceipts(userId)
        : _receiptService.getUserReceiptsByType(userId, _filterType);

    return StreamBuilder<List<Receipt>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final allReceipts = snapshot.data ?? [];
        
        // ✅ Apply additional filtering based on filter type
        final receipts = allReceipts.where((receipt) {
          // If "All" is selected, include all receipts except membership templates (amount <= 0)
          if (_filterType == 'all') {
            // Include all program_fee receipts (even with amount 0)
            if (receipt.receiptType == 'program_fee') {
              return true;
            }
            // For membership, only include if amount > 0 (exclude templates)
            if (receipt.receiptType == 'membership') {
              return receipt.amount > 0;
            }
            return true;
          }
          
          // If "Membership" is selected, include membership receipts with amount > 0
          if (_filterType == 'membership') {
            return receipt.receiptType == 'membership' && receipt.amount > 0;
          }
          
          // If "Program Fee" is selected, include all program_fee receipts (even with amount 0)
          if (_filterType == 'program_fee') {
            return receipt.receiptType == 'program_fee';
          }
          
          return true;
        }).toList();

        if (receipts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No receipts found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: receipts.length,
          itemBuilder: (context, index) {
            return _buildReceiptCard(receipts[index]);
          },
        );
      },
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
    final receiptTypeLabel = receipt.receiptType == 'membership'
        ? 'Membership Fee'
        : 'Program Fee';
    final statusColor = receipt.status == 'completed'
        ? Colors.green
        : receipt.status == 'pending'
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            receipt.receiptType == 'membership'
                ? Icons.card_membership
                : Icons.school,
            color: Colors.blue,
          ),
        ),
        title: Text(
          receiptTypeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Transaction ID: ${receipt.transactionId}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              dateFormatter.format(receipt.paymentDate),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'RM ${receipt.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                receipt.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _showReceiptDetails(context, receipt);
        },
      ),
    );
  }

  void _showReceiptDetails(BuildContext context, Receipt receipt) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final receiptTypeLabel = receipt.receiptType == 'membership'
        ? 'Membership Fee'
        : 'Program Fee';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Receipt Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),

                    // Details
                    _buildDetailTile('Receipt ID', receipt.id),
                    _buildDetailTile('Type', receiptTypeLabel),
                    _buildDetailTile(
                      'Payment Date',
                      dateFormatter.format(receipt.paymentDate),
                    ),
                    _buildDetailTile(
                      'Payment Method',
                      _formatPaymentMethod(receipt.paymentMethod),
                    ),
                    _buildDetailTile(
                      'Transaction ID',
                      receipt.transactionId,
                    ),
                    _buildDetailTile(
                      'Status',
                      receipt.status.toUpperCase(),
                    ),
                    _buildDetailTile(
                      'Amount',
                      'RM ${receipt.amount.toStringAsFixed(2)}',
                      isHighlight: true,
                    ),

                    // Additional details
                    if (receipt.details != null && receipt.details!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Additional Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...receipt.details!.entries.map((entry) {
                            return _buildDetailTile(
                              entry.key,
                              entry.value.toString(),
                            );
                          }).toList(),
                        ],
                      ),

                    const SizedBox(height: 30),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _downloadReceipt(receipt);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening receipt...'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download PDF'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailTile(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: isHighlight ? 16 : 14,
                color: isHighlight ? Colors.green : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReceipt(Receipt receipt) async {
    try {
      if (await canLaunchUrl(Uri.parse(receipt.pdfUrl))) {
        await launchUrl(
          Uri.parse(receipt.pdfUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open receipt')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'qr_code':
        return 'QR Code Payment';
      case 'card':
        return 'Credit/Debit Card';
      case 'transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }
}
