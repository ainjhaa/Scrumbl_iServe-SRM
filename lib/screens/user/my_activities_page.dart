import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/services/shared_pref.dart';
import 'package:demo_app/services/program_receipt_service.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:url_launcher/url_launcher.dart';

class MyActivitiesPage extends StatelessWidget {
  const MyActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Activities")),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 60, color: Colors.grey),
              SizedBox(height: 20),
              Text("Please log in to view your activities"),
            ],
          ),
        ),
      );
    }

    final userId = currentUser.uid;
    
    // Debug: Verify we're using the correct user
    print('🔍 MyActivities - User ID: $userId');
  
    return Scaffold(
      appBar: AppBar(title: const Text("My Activities")),
      body: StreamBuilder<DocumentSnapshot>(
        // First get user document to check role
        stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
        
          final userRole = userSnapshot.data!['role'] ?? 'Volunteer';
          print('🔍 User Role: $userRole');
        
          // Now get registered events
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
              .collection("users")
              .doc(userId)
              .collection("RegisteredEvents")
              .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

            final registeredEventDocs = snapshot.data!.docs;
            
            // Debug: Show what events we found
            print('🔍 Found ${registeredEventDocs.length} registered events');
            for (final doc in registeredEventDocs) {
              print('   - Event ID: ${doc.id}');
            }

            if (registeredEventDocs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 60, color: Colors.grey),
                    SizedBox(height: 20),
                    Text("You haven't registered for any activities yet."),
                  ],
                ),
              );
            }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: registeredEventDocs.length,
                itemBuilder: (context, index) {
                  final eventId = registeredEventDocs[index].id;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("Event")
                        .doc(eventId)
                        .get(),
                    builder: (context, eventSnapshot) {
                      if (!eventSnapshot.hasData) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final eventData = eventSnapshot.data!;
                      final eventName = eventData['Name'] ?? "Unnamed Event";
                      final eventDate = eventData['Date'] ?? "N/A";
                      final eventLocation = eventData['Location'] ?? "N/A";
                      final eventImage = eventData['Image'] ?? "";
                      final eventPrice = eventData['Price'] ?? "N/A";

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(userId)
                            .collection("Payments")
                            .doc(eventId)
                            .get(),
                        builder: (context, paymentSnapshot) {
                          final paymentData =
                              paymentSnapshot.data?.data() as Map<String, dynamic>?;
                          final receiptPdf = paymentData?['receiptPdf'];
                          final paymentDate = paymentData?['timestamp'];

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                // Event Image
                                eventImage.isNotEmpty
                                    ? Image.network(
                                        eventImage,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "images/event.jpg",
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventName,
                                        style: const TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 16),
                                          const SizedBox(width: 8),
                                          Text(eventDate),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(eventLocation)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.local_offer, size: 16),
                                          const SizedBox(width: 8),
                                          Text("Fee: $eventPrice"),
                                        ],
                                      ),
                                      if (paymentDate != null)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              "Registration Date: ${DateFormat('dd MMM yyyy').format((paymentDate as Timestamp).toDate())}",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      const SizedBox(height: 12),
                                      // ✅ Receipt Buttons - Only show for PAID events (not free events)
                                      // Check if this is NOT a free event
                                      if (eventPrice != "N/A" && eventPrice != "RM0" && eventPrice != "0")
                                        FutureBuilder<Receipt?>(
                                          future: _getProgramReceipt(userId, eventId),
                                          builder: (context, receiptSnapshot) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // Generated Receipt Button
                                                if (receiptSnapshot.hasData && receiptSnapshot.data != null)
                                                  Column(
                                                    children: [
                                                      ElevatedButton.icon(
                                                        onPressed: () {
                                                          final receipt = receiptSnapshot.data!;
                                                          _showGeneratedReceiptDialog(context, receipt);
                                                        },
                                                        icon: const Icon(Icons.receipt),
                                                        label: const Text("View Generated Receipt"),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.blue,
                                                          foregroundColor: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                // Uploaded Receipt Button
                                                if (receiptPdf != null)
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      _showReceiptDialog(context, receiptPdf);
                                                    },
                                                    icon: const Icon(Icons.picture_as_pdf),
                                                    label: const Text("View Uploaded Receipt"),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.green,
                                                      foregroundColor: Colors.white,
                                                    ),
                                                  )
                                                else
                                                  const Text(
                                                    "No receipt uploaded yet",
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      // ✅ For FREE events - Show confirmation message
                                      if (eventPrice == "RM0" || eventPrice == "0")
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                                              SizedBox(width: 8),
                                              Text(
                                                "Free event - No receipt required",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, String pdfUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Uploaded Receipt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Receipt URL:"),
            const SizedBox(height: 10),
            SelectableText(
              pdfUrl,
              style: const TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (await canLaunch(pdfUrl)) {
                await launch(pdfUrl);
              }
            },
            child: const Text("Open Link"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<Receipt?> _getProgramReceipt(String userId, String eventId) async {
    try {
      final programReceiptService = ProgramReceiptService();
      final receipts = await programReceiptService.getUserProgramReceipts(userId);
      
      for (final receipt in receipts) {
        if (receipt.details?['eventId'] == eventId) {
          return receipt;
        }
      }
      return null;
    } catch (e) {
      print("Error fetching program receipt: $e");
      return null;
    }
  }

  void _showGeneratedReceiptDialog(BuildContext context, Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Program Fee Receipt"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogRow("Receipt ID:", receipt.id),
              _buildDialogRow("Amount:", "RM ${receipt.amount.toStringAsFixed(2)}"),
              _buildDialogRow(
                "Payment Date:",
                DateFormat('dd MMM yyyy HH:mm').format(receipt.paymentDate),
              ),
              if (receipt.details != null) ...[
                const Divider(),
                const Text(
                  "Program Details:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildDialogRow("Event:", receipt.details!['eventName'] ?? "N/A"),
                _buildDialogRow("Date:", receipt.details!['eventDate'] ?? "N/A"),
                _buildDialogRow("Location:", receipt.details!['eventLocation'] ?? "N/A"),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (await canLaunch(receipt.pdfUrl)) {
                await launch(receipt.pdfUrl);
              }
            },
            child: const Text("Download PDF"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
