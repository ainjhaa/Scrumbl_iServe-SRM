import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/membership_payment_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:demo_app/models/receipt.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Stream<DocumentSnapshot> getMembershipStatus() {
    final user = FirebaseAuth.instance.currentUser!;
    // Listen to the volunteer’s registration doc (status updated by admin)
    return FirebaseFirestore.instance
        .collection('registrations')
        .doc(user.uid)
        .snapshots();
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    if (pickedFile == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final file = File(pickedFile!.path!);
      final path = 'registrations/${user.uid}/${pickedFile!.name}';
      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String name = userDoc['name'];
      String email = userDoc['email'] ?? user.email ?? '';

      final registrationData = {
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'fileName': pickedFile!.name,
        'fileUrl': urlDownload,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };

      // Save to volunteer's collection
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(user.uid)
          .set(registrationData);

      // Save to admin collection for approval
      await FirebaseFirestore.instance
          .collection('membership_requests')
          .doc(user.uid)
          .set(registrationData);

      // Generate and upload receipt
      await _generateAndUploadReceipt(
        userId: user.uid,
        userName: name,
        userEmail: email,
        fileName: pickedFile!.name,
      );

      setState(() => uploadTask = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("File uploaded successfully! Receipt generated."),
            duration: Duration(seconds: 2),
          ),
        );
      }

      print('Download Link: $urlDownload');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading file: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error: $e');
    }
  }

  Future<void> _generateAndUploadReceipt({
    required String userId,
    required String userName,
    required String userEmail,
    required String fileName,
  }) async {
    try {
      final receiptService = ReceiptUploadService();
      final transactionId = _generateNumericId();
      final now = DateTime.now();

      // Create receipt object with fixed RM10 membership fee
      final receipt = Receipt(
        id: _generateNumericId(),
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'membership',
        amount: 10.0, // Fixed membership fee RM10
        paymentDate: now,
        paymentMethod: 'QR Payment',
        transactionId: transactionId,
        status: 'pending', // Pending admin approval
        details: {
          'Document Name': fileName,
          'Registration Type': 'Club Membership Application',
          'Fee Type': 'Membership Registration',
          'Status': 'Awaiting Admin Approval',
        },
        pdfUrl: '',
        generatedAt: now,
      );

      // Generate PDF
      final pdfFile =
          await ReceiptGenerationService.generateReceiptPDF(receipt);

      // Upload PDF and save receipt to Firestore
      final uploadedReceipt = await receiptService.createAndUploadReceipt(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        receiptType: 'membership',
        amount: 10.0, // Fixed membership fee
        paymentMethod: 'QR Payment',
        transactionId: transactionId,
        status: 'pending',
        details: {
          'Document Name': fileName,
          'Registration Type': 'Club Membership Application',
          'Fee Type': 'Membership Registration',
          'Status': 'Awaiting Admin Approval',
        },
        pdfFile: pdfFile,
        receiptId: receipt.id,
      );

      // Delete temporary PDF file
      await pdfFile.delete().catchError((_) => pdfFile);

      print('Receipt generated and uploaded: ${uploadedReceipt.id}');
    } catch (e) {
      print('Error generating receipt: $e');
      // Don't fail the registration if receipt generation fails
    }
  }

  /// Generate numeric-only ID (no symbols)
  String _generateNumericId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString();
  }

  // In membership_page.dart - Update buildUploadSection method
Widget buildUploadSection() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        const Icon(Icons.workspace_premium, color: Colors.amber, size: 100),
        const SizedBox(height: 20),
        const Text(
          "Become a Premium Member",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "Access exclusive content, faster support, and VIP events!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        // Membership Fee Information
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Membership Fee: RM10.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pay once for annual membership',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Two Options: Pay Now or Upload Later
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Choose Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Option 1: Pay with QR Code
                ListTile(
                  leading: const Icon(Icons.qr_code, color: Colors.blue),
                  title: const Text('Pay Now with QR Code'),
                  subtitle: const Text('Scan QR code and upload receipt'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MembershipPaymentPage(
                          membershipType: 'club_membership',
                          amount: 10.0,
                          title: 'Premium Membership Payment',
                          description: 'Complete payment to proceed with membership application',
                          additionalDetails: {
                            'Fee Type': 'Annual Membership',
                            'Duration': '1 Year',
                            'Benefits': 'All premium features',
                          },
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),

                // Option 2: Upload Receipt Only
                ListTile(
                  leading: const Icon(Icons.upload_file, color: Colors.orange),
                  title: const Text('Upload Payment Receipt'),
                  subtitle: const Text('If you have already paid'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Show file upload section
                    _showUploadDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper method for upload only option
void _showUploadDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upload Payment Receipt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please upload your payment receipt.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: selectFile,
            child: const Text('Select File'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            if (pickedFile != null) {
              uploadFile();
            }
          },
          child: const Text('Upload'),
        ),
      ],
    ),
  );
}

  Widget buildPendingSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_top, color: Colors.orange, size: 100),
          SizedBox(height: 20),
          Text(
            "Your membership request is pending.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text("Please wait for admin approval."),
        ],
      ),
    );
  }

  Widget buildApprovedSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.verified, color: Colors.green, size: 100),
          SizedBox(height: 20),
          Text(
            "You are now a Premium Member!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildRejectedSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 100),
          const SizedBox(height: 20),
          const Text(
            "Your membership request was rejected.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // allow re-apply
              FirebaseFirestore.instance
                  .collection('membership_requests')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .delete();
              FirebaseFirestore.instance
                  .collection('registrations')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .delete();
              setState(() {
                pickedFile = null;
              });
            },
            child: const Text("Reapply"),
          )
        ],
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(height: 50);
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Membership Program")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getMembershipStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If user has NOT applied yet
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return buildUploadSection();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';

          if (status == 'pending') {
            return buildPendingSection();
          } else if (status == 'approved') {
            return buildApprovedSection();
          } else if (status == 'rejected') {
            return buildRejectedSection();
          }

          return buildUploadSection(); // fallback
        },
      ),
    );
  }
}
