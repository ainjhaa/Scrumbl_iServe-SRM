import 'dart:io';
import 'package:demo_app/models/receipt.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Theme colors: Maroon and Grey
const PdfColor _maroonColor = PdfColor.fromInt(0xFF800000); // Maroon
const PdfColor _darkGreyColor = PdfColor.fromInt(0xFF333333); // Dark Grey
const PdfColor _lightGreyColor = PdfColor.fromInt(0xFFF5F5F5); // Light Grey
const PdfColor _greyText = PdfColor.fromInt(0xFF666666); // Grey Text

class ReceiptGenerationService {
  /// Generate a PDF receipt for membership or program fee payment
  static Future<File> generateReceiptPDF(Receipt receipt) async {
    final pdf = pw.Document();

    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

    // Load logo image
    final logoImage = await _loadAssetImage('assets/srm_logo.png');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Center(
                child: pw.Column(
                  children: [
                    // Logo
                    if (logoImage != null)
                      pw.Image(
                        logoImage,
                        width: 80,
                        height: 80,
                      ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'RAKAN MUDA',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'iServe - SRM Platform',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: _greyText,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Divider(
                      height: 2,
                      color: _maroonColor,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Receipt Type
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _maroonColor),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  color: _lightGreyColor,
                ),
                child: pw.Center(
                  child: pw.Text(
                    'PAYMENT RECEIPT - ${receipt.receiptType.toUpperCase()}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _maroonColor,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Receipt ID and Date
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Receipt ID:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: _darkGreyColor,
                        ),
                      ),
                      pw.Text(
                        receipt.id,
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _greyText,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: _darkGreyColor,
                        ),
                      ),
                      pw.Text(
                        dateFormatter.format(receipt.generatedAt),
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _greyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Customer Information
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _lightGreyColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'MEMBER INFORMATION',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildDetailRow('Name:', receipt.userName),
                    _buildDetailRow('Email:', receipt.userEmail),
                    _buildDetailRow('User ID:', receipt.userId),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Payment Details
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _lightGreyColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT DETAILS',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    _buildDetailRow(
                      'Receipt Type:',
                      _formatReceiptType(receipt.receiptType),
                    ),
                    _buildDetailRow(
                      'Payment Method:',
                      _formatPaymentMethod(receipt.paymentMethod),
                    ),
                    _buildDetailRow(
                      'Transaction ID:',
                      receipt.transactionId,
                    ),
                    _buildDetailRow(
                      'Payment Date:',
                      dateFormatter.format(receipt.paymentDate),
                    ),
                    _buildDetailRow(
                      'Status:',
                      receipt.status.toUpperCase(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Amount Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: _maroonColor,
                    width: 2,
                  ),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  color: _lightGreyColor,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'AMOUNT PAID',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'RM ${receipt.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Additional Details if available
              if (receipt.details != null && receipt.details!.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: _lightGreyColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ADDITIONAL INFORMATION',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: _maroonColor,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      ...receipt.details!.entries.map((entry) {
                        return _buildDetailRow(
                          '${entry.key}:',
                          entry.value.toString(),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Divider(
                height: 2,
                color: _maroonColor,
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Thank you for your payment!',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: _maroonColor,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'This is an automated receipt generated by the iServe platform.',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: _greyText,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Contact us: support@rakanmuda.com',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: _greyText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'receipt_${receipt.receiptType}_${receipt.transactionId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: _darkGreyColor,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                color: _greyText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Load image from assets
  static Future<pw.ImageProvider?> _loadAssetImage(String assetPath) async {
    try {
      // Get the asset file from the assets directory
      final file = File(assetPath);
      if (await file.exists()) {
        return pw.MemoryImage(await file.readAsBytes());
      }
      return null;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  static String _formatReceiptType(String type) {
    switch (type) {
      case 'membership':
        return 'Club Membership Fee';
      case 'program_fee':
        return 'Program Fee';
      default:
        return type;
    }
  }

  static String _formatPaymentMethod(String method) {
    switch (method) {
      case 'QR Payment':
        return 'QR Code Payment';
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
