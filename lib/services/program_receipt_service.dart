import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:random_string/random_string.dart';

/// Service to handle receipt generation and storage for program registration
class ProgramReceiptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ReceiptUploadService _receiptUploader = ReceiptUploadService();

  /// Generate and save receipt for program registration
  Future<Map<String, dynamic>> generateProgramReceipt({
    required String userId,
    required String userName,
    required String userEmail,
    required String eventId,
    required String eventName,
    required String eventDate,
    required String eventLocation,
    required double amount,
    required String uploadedReceiptUrl, // User's uploaded receipt URL
  }) async {
    try {
      final receiptId = randomString(20);
      final now = DateTime.now();

      // Create receipt object for the program fee
      var receipt = Receipt(
        id: receiptId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'program_fee',
        amount: amount,
        paymentDate: now,
        paymentMethod: 'qr_code', // Default to QR code payment
        transactionId: eventId,
        status: 'completed',
        details: {
          'eventId': eventId,
          'eventName': eventName,
          'eventDate': eventDate,
          'eventLocation': eventLocation,
          'uploadedReceiptUrl': uploadedReceiptUrl, // Link to user's uploaded receipt
        },
        pdfUrl: '', // Will be updated after PDF generation
        generatedAt: now,
      );

      // Generate PDF receipt
      final pdfFile = await ReceiptGenerationService.generateReceiptPDF(receipt);

      // Upload PDF to Firebase Storage
      final pdfUrl = await _receiptUploader.uploadReceiptPDF(pdfFile, userId);

      // Update receipt with PDF URL
      receipt = Receipt(
        id: receiptId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'program_fee',
        amount: amount,
        paymentDate: now,
        paymentMethod: 'qr_code',
        transactionId: eventId,
        status: 'completed',
        details: {
          'eventId': eventId,
          'eventName': eventName,
          'eventDate': eventDate,
          'eventLocation': eventLocation,
          'uploadedReceiptUrl': uploadedReceiptUrl,
        },
        pdfUrl: pdfUrl,
        generatedAt: now,
      );

      // Save receipt to Firestore in multiple locations
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receiptId)
          .set(receipt.toMap());

      // Save to general receipts collection
      await _firestore
          .collection('receipts')
          .doc(receiptId)
          .set(receipt.toMap());

      // Also save in program receipts subcollection for easy access
      await _firestore
          .collection('Event')
          .doc(eventId)
          .collection('Receipts')
          .doc(userId)
          .set({
        ...receipt.toMap(),
        'receiptId': receiptId,
      });

      // Clean up temporary file
      pdfFile.deleteSync();

      return {
        'receiptId': receiptId,
        'pdfUrl': pdfUrl,
        'success': true,
      };
    } catch (e) {
      print('Error generating program receipt: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Retrieve program receipts for a user
  Future<List<Receipt>> getUserProgramReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .where('receiptType', isEqualTo: 'program_fee')
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Receipt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error retrieving program receipts: $e');
      return [];
    }
  }

  /// Retrieve all receipts for a user (both membership and program)
  Future<List<Receipt>> getAllUserReceipts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Receipt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error retrieving all receipts: $e');
      return [];
    }
  }
}
