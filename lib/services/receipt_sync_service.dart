import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';

/// Service to handle receipt generation for existing registrations and payments
class ReceiptSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final ReceiptUploadService _receiptService = ReceiptUploadService();

  /// Generate numeric-only ID (no symbols)
  static String _generateNumericId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  /// Generate receipts for a user's existing membership registration
  static Future<void> generateMembershipRegistrationReceipt(
    String userId,
  ) async {
    try {
      // Check if receipt already exists
      final existingReceipts = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .where('receiptType', isEqualTo: 'membership')
          .where('paymentMethod', isEqualTo: 'QR Payment')
          .get();

      if (existingReceipts.docs.isNotEmpty) {
        print('Receipt already exists for user $userId');
        return;
      }

      // Get user data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data() as Map<String, dynamic>;
      final userName = userData['name'] ?? 'User';
      final userEmail = userData['email'] ?? '';

      // Get registration data
      final regDoc = await _firestore
          .collection('registrations')
          .doc(userId)
          .get();

      if (!regDoc.exists) return;

      final regData = regDoc.data() as Map<String, dynamic>;
      final fileName = regData['fileName'] ?? 'Document';
      final uploadedAt = regData['uploadedAt'] as Timestamp?;
      final registrationDate = uploadedAt?.toDate() ?? DateTime.now();

      // Create receipt with RM10 fixed fee
      final receipt = Receipt(
        id: _generateNumericId(),
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'membership',
        amount: 10.0, // Fixed RM10 membership fee
        paymentDate: registrationDate,
        paymentMethod: 'QR Payment',
        transactionId: _generateNumericId(),
        status: regData['status'] ?? 'pending',
        details: {
          'Document Name': fileName,
          'Registration Type': 'Club Membership Application',
          'Status': regData['status'] ?? 'Pending',
        },
        pdfUrl: '',
        generatedAt: DateTime.now(),
      );

      // Generate PDF
      final pdfFile =
          await ReceiptGenerationService.generateReceiptPDF(receipt);

      // Upload receipt
      await _receiptService.createAndUploadReceipt(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'membership',
        amount: 10.0, // Fixed RM10 membership fee
        paymentMethod: 'QR Payment',
        transactionId: receipt.transactionId,
        status: receipt.status,
        details: receipt.details,
        pdfFile: pdfFile,
      );

      // Cleanup
      await pdfFile.delete().catchError((_) => pdfFile);

      print('Membership registration receipt generated for user $userId');
    } catch (e) {
      print('Error generating membership registration receipt: $e');
    }
  }

  /// Generate receipts for all users with pending or approved memberships but no receipt
  static Future<void> syncMembershipReceiptsForAllUsers() async {
    try {
      // Get all registrations
      final registrations = await _firestore
          .collection('registrations')
          .where('status', whereIn: ['pending', 'approved']).get();

      for (final reg in registrations.docs) {
        await generateMembershipRegistrationReceipt(reg.id);
      }

      print('Synced receipts for ${registrations.docs.length} users');
    } catch (e) {
      print('Error syncing receipts: $e');
    }
  }
}
