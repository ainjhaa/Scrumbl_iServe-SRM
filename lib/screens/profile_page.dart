import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/screens/receipt_history_page.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:demo_app/services/receipt_sync_service.dart';
import 'package:demo_app/models/receipt.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = getUserData();
    // Sync receipts for existing users
    _initializeReceipts();
  }

  Future<void> _initializeReceipts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Generate receipt for membership registration if it doesn't exist
      await ReceiptSyncService.generateMembershipRegistrationReceipt(user.uid);
      
      // Delete any RM0 (zero amount) membership receipts
      final receiptService = ReceiptUploadService();
      await receiptService.deleteZeroAmountMembershipReceipts(user.uid);
    }
  }

  Future<DocumentSnapshot?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<DocumentSnapshot?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // 🔄 Loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ No user data found
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Unable to load user data."),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 60),
                ),

                const SizedBox(height: 20),

                // Name
                Row(
                  children: [
                    const Icon(Icons.person, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["name"] ?? "No Name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                // Email
                Row(
                  children: [
                    const Icon(Icons.email, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["email"] ?? "No Email",
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                // Role
                Row(
                  children: [
                    const Icon(Icons.badge, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["role"] ?? "Volunteer",
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                // Payment History Section
                _buildPaymentHistorySection(context, snapshot.data!.reference.id),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Payment History Section
  Widget _buildPaymentHistorySection(BuildContext context, String userId) {
    final receiptService = ReceiptUploadService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceiptHistoryPage(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Recent Payments List
        StreamBuilder<List<Receipt>>(
          stream: receiptService.getUserReceipts(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Error loading payments'),
                    ),
                  ],
                ),
              );
            }

            final receipts = snapshot.data ?? [];

            // Show empty state
            if (receipts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No payments yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show last 3 payments
            final recentReceipts = receipts.take(3).toList();

            return Column(
              children: List.generate(
                recentReceipts.length,
                (index) => _buildPaymentCard(
                  context,
                  recentReceipts[index],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Payment Card Widget
  Widget _buildPaymentCard(BuildContext context, Receipt receipt) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final receiptTypeLabel = receipt.receiptType == 'membership'
        ? 'Membership Fee'
        : 'Program Fee';
    final statusColor = receipt.status == 'completed'
        ? Colors.green
        : receipt.status == 'pending'
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
            size: 20,
          ),
        ),
        title: Text(
          receiptTypeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          dateFormatter.format(receipt.paymentDate),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'RM ${receipt.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                receipt.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _showPaymentDetails(context, receipt);
        },
      ),
    );
  }

  // Payment Details Dialog
  void _showPaymentDetails(BuildContext context, Receipt receipt) {
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
                      'Payment Details',
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
                          _downloadReceipt(context, receipt);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Receipt PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
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

  // Detail Tile
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

  // Download Receipt
  Future<void> _downloadReceipt(BuildContext context, Receipt receipt) async {
    try {
      if (await canLaunchUrl(Uri.parse(receipt.pdfUrl))) {
        await launchUrl(
          Uri.parse(receipt.pdfUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open receipt')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
