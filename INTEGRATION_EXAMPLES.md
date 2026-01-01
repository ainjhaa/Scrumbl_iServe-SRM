# Integration Examples - How to Use Receipt Features

## Example 1: Add Receipt History to Profile Page

Update your profile page to include a receipt history button:

```dart
// In lib/screens/profile_page.dart

import 'package:demo_app/screens/receipt_history_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // ... existing profile content ...
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Payment Receipts'),
            subtitle: const Text('View and download your receipts'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiptHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

## Example 2: Add Payment Button to Membership Page

Update your membership page to include payment option:

```dart
// In lib/screens/membership_page.dart

import 'package:demo_app/screens/membership_payment_page.dart';

class MembershipPage extends StatefulWidget {
  // ... existing code ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Membership Program")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: getMembershipStatus(),
        builder: (context, snapshot) {
          // ... existing status checks ...

          // If user is not a member yet, show upgrade option
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, 
                    color: Colors.amber, size: 100),
                  const SizedBox(height: 20),
                  const Text(
                    "Become a Premium Member",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // NEW: Add payment button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MembershipPaymentPage(
                            membershipType: 'club_membership',
                            amount: 50.0,
                            title: 'Club Membership Fee',
                            description: 'Pay RM 50 to become a premium member',
                            additionalDetails: {
                              'Membership Duration': '1 Year',
                              'Benefits': 'Access to all events and activities',
                              'Support': '24/7 Member Support',
                              'Exclusive Content': 'Yes',
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Pay Membership Fee (RM 50)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // ... rest of existing code ...
        },
      ),
    );
  }
}
```

## Example 3: Add Program Fee Payment to Events

Allow users to pay program fees when registering for programs:

```dart
// In lib/screens/event_detail_page.dart

import 'package:demo_app/screens/membership_payment_page.dart';

class EventDetailPage extends StatelessWidget {
  final Event event;

  EventDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... existing event details ...

            const SizedBox(height: 24),
            
            // NEW: Payment section for paid programs
            if (event.price > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Program Fee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enrollment Fee:'),
                        Text(
                          'RM ${event.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MembershipPaymentPage(
                              membershipType: 'program_fee',
                              amount: event.price,
                              title: '${event.title} - Enrollment',
                              description: 'Pay the program enrollment fee',
                              additionalDetails: {
                                'Program': event.title,
                                'Duration': event.duration ?? 'Not specified',
                                'Sessions': event.sessions ?? 'Not specified',
                                'Instructor': event.instructor ?? 'Not specified',
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Pay Program Fee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),
            
            // Register button (if free or already paid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle registration
                },
                child: const Text('Register for Program'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Example 4: Add Receipts to Navigation Bar

Add receipt history as a tab in your main navigation:

```dart
// In lib/screens/home_page.dart

import 'package:demo_app/screens/receipt_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EventsScreen(),
    const ProgramsScreen(),
    const ReceiptHistoryPage(),  // NEW: Add receipt screen
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),  // NEW: Receipt tab
            label: 'Receipts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
```

## Example 5: Show Receipt Options in User Menu

Add receipt viewing to a user dropdown menu:

```dart
// In a user menu/drawer

PopupMenuButton(
  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
    PopupMenuItem(
      child: const Text('View Profile'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      },
    ),
    PopupMenuItem(
      child: const Text('Payment Receipts'),  // NEW
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReceiptHistoryPage(),
          ),
        );
      },
    ),
    const PopupMenuDivider(),
    PopupMenuItem(
      child: const Text('Logout'),
      onTap: () {
        // Handle logout
      },
    ),
  ],
)
```

## Example 6: Dialog After Payment Success

Show receipt after successful payment:

```dart
// In your payment handler

void handlePaymentSuccess(Receipt receipt) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Payment Successful'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Receipt ID: ${receipt.id}'),
          Text('Amount: RM ${receipt.amount.toStringAsFixed(2)}'),
          Text('Status: ${receipt.status}'),
          const SizedBox(height: 16),
          const Text(
            'Your receipt has been saved and can be accessed anytime from Receipt History.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReceiptHistoryPage(),
              ),
            );
          },
          child: const Text('View Receipts'),
        ),
      ],
    ),
  );
}
```

## Example 7: Add Receipt Download to Admin Panel

Allow admins to view and download member receipts:

```dart
// In admin panel (admin member view)

class AdminMemberReceiptsView extends StatelessWidget {
  final String userId;
  final ReceiptUploadService _receiptService = ReceiptUploadService();

  AdminMemberReceiptsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Receipts')),
      body: StreamBuilder<List<Receipt>>(
        stream: _receiptService.getUserReceipts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final receipts = snapshot.data ?? [];

          return ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return ListTile(
                title: Text(receipt.receiptType),
                subtitle: Text('RM ${receipt.amount.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Download receipt
                    _downloadReceipt(receipt);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _downloadReceipt(Receipt receipt) async {
    try {
      if (await canLaunchUrl(Uri.parse(receipt.pdfUrl))) {
        await launchUrl(Uri.parse(receipt.pdfUrl));
      }
    } catch (e) {
      print('Error downloading: $e');
    }
  }
}
```

## Example 8: Manual Receipt Generation (Advanced)

If you need to manually generate a receipt outside the normal flow:

```dart
import 'package:demo_app/models/receipt.dart';
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:random_string/random_string.dart';

// Generate receipt manually
Future<void> generateManualReceipt({
  required String userId,
  required String userName,
  required String userEmail,
  required double amount,
  required String receiptType,
}) async {
  try {
    // Create receipt object
    final receipt = Receipt(
      id: randomString(20),
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      receiptType: receiptType,
      amount: amount,
      paymentDate: DateTime.now(),
      paymentMethod: 'qr_code',
      transactionId: randomString(16),
      status: 'completed',
      details: null,
      pdfUrl: '',
      generatedAt: DateTime.now(),
    );

    // Generate PDF
    final pdfFile = 
      await ReceiptGenerationService.generateReceiptPDF(receipt);

    // Upload and save
    final service = ReceiptUploadService();
    final uploadedReceipt = await service.createAndUploadReceipt(
      userId: receipt.userId,
      userName: receipt.userName,
      userEmail: receipt.userEmail,
      receiptType: receipt.receiptType,
      amount: receipt.amount,
      paymentMethod: receipt.paymentMethod,
      transactionId: receipt.transactionId,
      status: receipt.status,
      pdfFile: pdfFile,
    );

    print('Receipt created: ${uploadedReceipt.id}');
  } catch (e) {
    print('Error: $e');
  }
}
```

## Implementation Checklist

- [ ] Add imports to your screens
- [ ] Add navigation to receipt history
- [ ] Add payment buttons to membership page
- [ ] Add program fee payment to events
- [ ] Update profile page with receipt link
- [ ] Add receipt tab to navigation (optional)
- [ ] Test payment flow
- [ ] Test receipt generation
- [ ] Test receipt download
- [ ] Verify Firebase rules are correct
- [ ] Deploy to production

## Notes

- All examples use the new receipt system
- Modify amounts and descriptions as needed
- Customize the additional details for your use case
- Test thoroughly before deploying to users
