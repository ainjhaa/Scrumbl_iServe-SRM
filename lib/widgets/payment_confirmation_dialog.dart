import 'package:flutter/material.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';

class PaymentConfirmationDialog extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;
  final double amount;
  final String receiptType; // 'membership' or 'program_fee'
  final String paymentMethod;
  final Map<String, dynamic>? additionalDetails;
  final VoidCallback? onConfirm;

  const PaymentConfirmationDialog({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
    required this.amount,
    required this.receiptType,
    required this.paymentMethod,
    this.additionalDetails,
    this.onConfirm,
  });

  @override
  State<PaymentConfirmationDialog> createState() =>
      _PaymentConfirmationDialogState();
}

class _PaymentConfirmationDialogState extends State<PaymentConfirmationDialog> {
  bool _isProcessing = false;
  final ReceiptUploadService _receiptService = ReceiptUploadService();

  Future<void> _generateAndUploadReceipt() async {
    setState(() => _isProcessing = true);

    try {
      // Create a temporary receipt object
      final transactionId = _generateNumericId();
      final now = DateTime.now();

      // Create receipt object first
      final receipt = Receipt(
        id: _generateNumericId(),
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        receiptType: widget.receiptType,
        amount: widget.amount,
        paymentDate: now,
        paymentMethod: 'QR Payment',
        transactionId: transactionId,
        status: 'completed',
        details: widget.additionalDetails,
        pdfUrl: '', // Will be updated after PDF generation
        generatedAt: now,
      );

      // Generate PDF
      final pdfFile = await ReceiptGenerationService.generateReceiptPDF(receipt);

      // Upload PDF and update receipt
      final uploadedReceipt = await _receiptService.createAndUploadReceipt(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
        receiptType: widget.receiptType,
        amount: widget.amount,
        paymentMethod: 'QR Payment',
        transactionId: transactionId,
        status: 'completed',
        details: widget.additionalDetails,
        pdfFile: pdfFile,
        receiptId: receipt.id,
      );

      // Delete temporary PDF file
      await pdfFile.delete().catchError((_) => pdfFile);

      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog(uploadedReceipt);
        widget.onConfirm?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate numeric-only ID (no symbols)
  String _generateNumericId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  void _showSuccessDialog(Receipt receipt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildInfoRow('Amount Paid', 'RM ${receipt.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildInfoRow('Transaction ID', receipt.transactionId),
              const SizedBox(height: 8),
              _buildInfoRow(
                'Receipt Type',
                receipt.receiptType == 'membership'
                    ? 'Membership Fee'
                    : 'Program Fee',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your receipt has been generated and saved. You can view it anytime in the Receipt History.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptTypeLabel = widget.receiptType == 'membership'
        ? 'Membership Fee'
        : 'Program Fee';

    return AlertDialog(
      title: const Text('Confirm Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', receiptTypeLabel),
                const SizedBox(height: 12),
                _buildDetailRow('Name', widget.userName),
                const SizedBox(height: 12),
                _buildDetailRow('Email', widget.userEmail),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'RM ${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'After confirmation, a PDF receipt will be automatically generated and saved to your account.',
            style: TextStyle(
              fontSize: 12,
              color: Color.fromRGBO(117, 117, 117, 1),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _generateAndUploadReceipt,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : const Text('Confirm & Generate Receipt'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
