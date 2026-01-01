import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';

class ReceiptUploadService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// Upload PDF receipt to Firebase Storage
  Future<String> uploadReceiptPDF(File pdfFile, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'receipt_${userId}_$timestamp.pdf';
      final path = 'receipts/$userId/$fileName';

      final ref = _firebaseStorage.ref().child(path);
      final uploadTask = ref.putFile(pdfFile);

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }

  /// Save receipt details to Firestore
  Future<void> saveReceiptToFirestore(Receipt receipt) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(receipt.userId)
          .collection('receipts')
          .doc(receipt.id)
          .set(receipt.toMap());

      // Also save to general receipts collection for admin access
      await _firebaseFirestore
          .collection('receipts')
          .doc(receipt.id)
          .set(receipt.toMap());
    } catch (e) {
      throw Exception('Failed to save receipt to Firestore: $e');
    }
  }

  /// Create and upload receipt in one operation
  Future<Receipt> createAndUploadReceipt({
    required String userId,
    required String userName,
    required String userEmail,
    required String receiptType,
    required double amount,
    required String paymentMethod,
    required String transactionId,
    required String status,
    Map<String, dynamic>? details,
    required File pdfFile,
    String? receiptId,
  }) async {
    try {
      final finalReceiptId = receiptId ?? randomString(20);
      final now = DateTime.now();

      // Upload PDF
      final pdfUrl = await uploadReceiptPDF(pdfFile, userId);

      // Create receipt object
      final receipt = Receipt(
        id: finalReceiptId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: receiptType,
        amount: amount,
        paymentDate: now,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        status: status,
        details: details,
        pdfUrl: pdfUrl,
        generatedAt: now,
      );

      // Save to Firestore
      await saveReceiptToFirestore(receipt);

      return receipt;
    } catch (e) {
      throw Exception('Failed to create and upload receipt: $e');
    }
  }

  /// Get all receipts for a user
  Stream<List<Receipt>> getUserReceipts(String userId) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('receipts')
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Receipt.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get receipts by type (membership or program_fee)
  Stream<List<Receipt>> getUserReceiptsByType(String userId, String receiptType) {
    return _firebaseFirestore
        .collection('users')
        .doc(userId)
        .collection('receipts')
        .where('receiptType', isEqualTo: receiptType)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Receipt.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get a single receipt
  Future<Receipt?> getReceipt(String userId, String receiptId) async {
    try {
      final doc = await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receiptId)
          .get();

      if (doc.exists) {
        return Receipt.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get receipt: $e');
    }
  }

  /// Delete a receipt
  Future<void> deleteReceipt(String userId, String receiptId) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receiptId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  /// Update receipt status
  Future<void> updateReceiptStatus(
    String userId,
    String receiptId,
    String newStatus,
  ) async {
    try {
      await _firebaseFirestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receiptId)
          .update({'status': newStatus});
    } catch (e) {
      throw Exception('Failed to update receipt status: $e');
    }
  }
}
