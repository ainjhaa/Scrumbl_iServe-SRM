# Receipt Generation & Payment Feature Integration Guide

## Overview
This guide explains how to integrate the new receipt generation and payment features into your Flutter app.

## Files Added

### Models
- **`lib/models/receipt.dart`** - Receipt data model for storing receipt information

### Services
- **`lib/services/receipt_generation_service.dart`** - Service to generate PDF receipts
- **`lib/services/receipt_upload_service.dart`** - Service to upload receipts to Firebase Storage and Firestore

### Screens
- **`lib/screens/receipt_history_page.dart`** - Screen to view and download saved receipts
- **`lib/screens/membership_payment_page.dart`** - Payment page with QR code and receipt generation

### Widgets
- **`lib/widgets/payment_confirmation_dialog.dart`** - Dialog to confirm payment and generate receipt

## Setup Steps

### 1. Install Dependencies
The following packages have been added to `pubspec.yaml`:
```yaml
pdf: ^3.10.6
printing: ^5.11.3
path_provider: ^2.1.1
```

Run `flutter pub get` to install these packages.

### 2. Update Routes in main.dart
Add routes for the new screens in your `main.dart`:

```dart
routes: {
  '/welcome': (_) => const WelcomePage(),
  '/login': (_) => const LoginPage(),
  '/forgot': (_) => const ForgotPasswordPage(),
  '/signup': (_) => const SignUpPage(),
  '/home': (_) => const HomePage(),
  '/receipt-history': (_) => const ReceiptHistoryPage(),
  // Add membership payment routes
  '/membership-payment': (_) => const MembershipPaymentPage(
    membershipType: 'club_membership',
    amount: 50.0,
    title: 'Club Membership',
    description: 'Join our club and enjoy exclusive benefits',
  ),
  '/program-fee': (_) => const MembershipPaymentPage(
    membershipType: 'program_fee',
    amount: 100.0,
    title: 'Program Fee',
    description: 'Enroll in our special programs',
  ),
},
```

## Usage Examples

### 1. Open Receipt History Screen
```dart
Navigator.pushNamed(context, '/receipt-history');
```

### 2. Open Payment Screen for Club Membership
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MembershipPaymentPage(
      membershipType: 'club_membership',
      amount: 50.0,
      title: 'Club Membership Fee',
      description: 'Become a member of our club',
      additionalDetails: {
        'Membership Duration': '1 Year',
        'Benefits': 'Access to all events',
        'Support': '24/7 Member Support',
      },
    ),
  ),
);
```

### 3. Open Payment Screen for Program Fee
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MembershipPaymentPage(
      membershipType: 'program_fee',
      amount: 100.0,
      title: 'Program Enrollment Fee',
      description: 'Enroll in our training program',
      additionalDetails: {
        'Program Duration': '3 Months',
        'Classes': '12 Sessions',
        'Certification': 'Yes',
      },
    ),
  ),
);
```

### 4. Manually Trigger Receipt Generation (Advanced)
```dart
import 'package:demo_app/services/receipt_generation_service.dart';
import 'package:demo_app/services/receipt_upload_service.dart';
import 'package:demo_app/models/receipt.dart';

// Create a Receipt object
final receipt = Receipt(
  id: 'receipt_001',
  userId: 'user_123',
  userName: 'John Doe',
  userEmail: 'john@example.com',
  receiptType: 'membership',
  amount: 50.0,
  paymentDate: DateTime.now(),
  paymentMethod: 'qr_code',
  transactionId: 'TXN_12345',
  status: 'completed',
  details: {'Membership Type': 'Premium'},
  pdfUrl: '',
  generatedAt: DateTime.now(),
);

// Generate PDF
final pdfFile = await ReceiptGenerationService.generateReceiptPDF(receipt);

// Upload and save
final uploadService = ReceiptUploadService();
final uploadedReceipt = await uploadService.createAndUploadReceipt(
  userId: receipt.userId,
  userName: receipt.userName,
  userEmail: receipt.userEmail,
  receiptType: receipt.receiptType,
  amount: receipt.amount,
  paymentMethod: receipt.paymentMethod,
  transactionId: receipt.transactionId,
  status: receipt.status,
  details: receipt.details,
  pdfFile: pdfFile,
);
```

## Firestore Data Structure

### Users Collection
Each user has a `receipts` subcollection:
```
users/
  {userId}/
    receipts/
      {receiptId}/
        id: string
        userId: string
        userName: string
        userEmail: string
        receiptType: 'membership' | 'program_fee'
        amount: number
        paymentDate: timestamp
        paymentMethod: string
        transactionId: string
        status: string
        details: object (optional)
        pdfUrl: string
        generatedAt: timestamp
```

### General Receipts Collection
All receipts are also saved to:
```
receipts/
  {receiptId}/
    [same fields as above]
```

## Features

### Receipt Generation Service
- ✅ Generate professional PDF receipts
- ✅ Includes member information
- ✅ Shows payment details (amount, date, transaction ID)
- ✅ Displays payment status
- ✅ Includes additional details (membership type, program info, etc.)
- ✅ Professional formatting with header and footer

### Receipt Upload Service
- ✅ Upload PDF to Firebase Storage
- ✅ Save receipt details to Firestore
- ✅ Retrieve user's receipt history
- ✅ Filter receipts by type (membership or program fee)
- ✅ Update receipt status
- ✅ Delete receipts

### Receipt History Page
- ✅ View all receipts
- ✅ Filter by receipt type
- ✅ View receipt details in a modal
- ✅ Download/open PDF receipts
- ✅ Display payment status with color indicators

### Payment Confirmation Dialog
- ✅ Confirm payment details
- ✅ Show member information
- ✅ Generate receipt automatically on confirmation
- ✅ Upload receipt to Firebase
- ✅ Show success message with transaction details

## Customization

### Customize Receipt Template
Edit `lib/services/receipt_generation_service.dart` to modify:
- Company name and logo
- Receipt layout and colors
- Font sizes and styles
- Fields to display
- Footer information

### Customize Payment Screen
Edit `lib/screens/membership_payment_page.dart` to:
- Change the QR code image
- Modify payment method options
- Add more payment details
- Customize UI colors and styles

### Customize Receipt History
Edit `lib/screens/receipt_history_page.dart` to:
- Change filter options
- Modify card layout
- Customize detail display
- Add more actions (print, share, etc.)

## Integration with Existing Code

### Option 1: Add Payment Option to Membership Page
Update your existing membership page to include a payment button:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MembershipPaymentPage(
          membershipType: 'club_membership',
          amount: 50.0,
          title: 'Club Membership Fee',
          description: 'Complete payment to join',
        ),
      ),
    );
  },
  child: const Text('Pay Membership Fee'),
),
```

### Option 2: Add Receipt History Button to Profile Page
Add a button in your profile page to view receipts:

```dart
ListTile(
  leading: const Icon(Icons.receipt),
  title: const Text('Receipt History'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReceiptHistoryPage(),
      ),
    );
  },
),
```

### Option 3: Add to Navigation Menu
Add receipt history to your main navigation:

```dart
BottomNavigationBarItem(
  icon: const Icon(Icons.receipt),
  label: 'Receipts',
),
```

Then handle the navigation:
```dart
case 3:
  // Show receipt history
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ReceiptHistoryPage(),
    ),
  );
  break;
```

## Security Considerations

1. **Firebase Rules**: Ensure your Firestore rules allow users to access only their own receipts:
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/receipts/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

2. **PDF Storage**: PDFs are stored in Firebase Storage with user-specific paths preventing unauthorized access.

3. **Data Validation**: All receipt data is validated before saving.

## Error Handling

The services include comprehensive error handling:
- File upload failures
- Network errors
- Invalid data
- Authentication issues

All errors are properly caught and displayed to the user.

## Testing

### Test Receipt Generation
```dart
// Create a test receipt
final testReceipt = Receipt(
  id: 'test_001',
  userId: 'test_user',
  userName: 'Test User',
  userEmail: 'test@example.com',
  receiptType: 'membership',
  amount: 50.0,
  paymentDate: DateTime.now(),
  paymentMethod: 'qr_code',
  transactionId: 'TEST_123',
  status: 'completed',
  details: null,
  pdfUrl: '',
  generatedAt: DateTime.now(),
);

// Generate and verify PDF
final pdfFile = await ReceiptGenerationService.generateReceiptPDF(testReceipt);
print('PDF created at: ${pdfFile.path}');
```

## Troubleshooting

### PDF not generating
- Ensure `path_provider` is properly initialized
- Check write permissions on device
- Verify `pdf` package is installed

### Receipts not uploading to Firebase
- Check Firebase Storage rules
- Verify user is authenticated
- Check network connectivity
- Review Firebase console for errors

### Receipt history not loading
- Verify Firestore rules allow read access
- Check user authentication
- Ensure receipts exist in Firestore

### Download not working
- Check PDF URL is valid
- Verify `url_launcher` is properly configured
- Check internet connectivity

## Future Enhancements

Consider adding:
- Email receipt delivery
- Receipt sharing functionality
- Digital signature on receipts
- Receipt printing capability
- Tax invoice generation
- Refund receipt generation
- Multi-language support
- Invoice generation for programs
