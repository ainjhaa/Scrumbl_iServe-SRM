# Receipt Feature - Quick Reference

## Files Overview

| File | Purpose |
|------|---------|
| `lib/models/receipt.dart` | Receipt data model |
| `lib/services/receipt_generation_service.dart` | PDF generation |
| `lib/services/receipt_upload_service.dart` | Firebase upload & retrieval |
| `lib/screens/receipt_history_page.dart` | View & download receipts |
| `lib/screens/membership_payment_page.dart` | Payment page with QR |
| `lib/widgets/payment_confirmation_dialog.dart` | Payment confirmation |

## Key Classes

### Receipt Model
```dart
Receipt(
  id: string,
  userId: string,
  userName: string,
  userEmail: string,
  receiptType: 'membership' | 'program_fee',
  amount: double,
  paymentDate: DateTime,
  paymentMethod: 'qr_code',
  transactionId: string,
  status: 'pending' | 'completed' | 'failed',
  details: Map<String, dynamic>?,
  pdfUrl: string,
  generatedAt: DateTime,
)
```

## Service Methods

### ReceiptGenerationService
```dart
// Generate PDF from Receipt object
Future<File> generateReceiptPDF(Receipt receipt)
```

### ReceiptUploadService
```dart
// Upload PDF and create receipt
Future<Receipt> createAndUploadReceipt({...})

// Get user's receipts
Stream<List<Receipt>> getUserReceipts(String userId)

// Get receipts by type
Stream<List<Receipt>> getUserReceiptsByType(String userId, String type)

// Get single receipt
Future<Receipt?> getReceipt(String userId, String receiptId)

// Update status
Future<void> updateReceiptStatus(String userId, String receiptId, String status)

// Delete receipt
Future<void> deleteReceipt(String userId, String receiptId)
```

## Common Tasks

### Show Payment Page
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MembershipPaymentPage(
      membershipType: 'club_membership',
      amount: 50.0,
      title: 'Club Membership',
      description: 'Join our club',
      additionalDetails: {'Duration': '1 Year'},
    ),
  ),
);
```

### Show Receipt History
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ReceiptHistoryPage(),
  ),
);
```

### Generate Receipt Manually
```dart
final receipt = Receipt(...);
final pdfFile = await ReceiptGenerationService.generateReceiptPDF(receipt);

final service = ReceiptUploadService();
final uploaded = await service.createAndUploadReceipt(
  userId: receipt.userId,
  userName: receipt.userName,
  userEmail: receipt.userEmail,
  receiptType: receipt.receiptType,
  amount: receipt.amount,
  paymentMethod: 'qr_code',
  transactionId: 'TXN_123',
  status: 'completed',
  pdfFile: pdfFile,
);
```

### Get User Receipts
```dart
final service = ReceiptUploadService();
service.getUserReceipts(userId).listen((receipts) {
  // Use receipts
});
```

## Firestore Queries

### Get all receipts for a user
```dart
db.collection('users')
  .doc(userId)
  .collection('receipts')
  .orderBy('generatedAt', descending: true)
  .get()
```

### Get membership receipts only
```dart
db.collection('users')
  .doc(userId)
  .collection('receipts')
  .where('receiptType', isEqualTo: 'membership')
  .get()
```

### Get completed payments
```dart
db.collection('receipts')
  .where('status', isEqualTo: 'completed')
  .get()
```

## Required Dependencies
```yaml
pdf: ^3.10.6
printing: ^5.11.3
path_provider: ^2.1.1
firebase_storage: ^13.0.4  # Already in project
cloud_firestore: ^6.1.0    # Already in project
firebase_auth: ^6.1.2       # Already in project
```

## Error Handling

All services throw meaningful exceptions:
```dart
try {
  final receipt = await service.getReceipt(userId, receiptId);
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

## Receipt Types
- `'membership'` - Club membership payment
- `'program_fee'` - Program enrollment fee

## Payment Methods
- `'qr_code'` - QR code payment (primary)
- `'card'` - Credit/debit card (for future)
- `'transfer'` - Bank transfer (for future)

## Receipt Statuses
- `'pending'` - Payment initiated
- `'completed'` - Payment successful
- `'failed'` - Payment failed

## PDF Receipt Contents
- Header with branding
- Receipt ID and timestamp
- Member information
- Payment details (amount, date, transaction ID)
- Payment status
- Additional details (membership duration, benefits, etc.)
- Footer with contact information

## UI Components

### Receipt Card
Displays receipt summary with:
- Receipt type icon
- Type label
- Transaction ID
- Payment date
- Amount (highlighted)
- Status badge

### Receipt Details Modal
Shows:
- All receipt information
- Additional details
- Download button

### Payment Page
Includes:
- Amount display
- Benefits list
- QR code display
- Action buttons

## Security

### Firestore Rules
```firestore
match /users/{userId}/receipts/{document=**} {
  allow read, write: if request.auth.uid == userId;
}
```

### Storage Rules
```firestore
match /receipts/{userId}/{document=**} {
  allow read: if request.auth.uid == userId;
}
```

## Customization

### Change Receipt Template
Edit `ReceiptGenerationService.generateReceiptPDF()` to modify:
- Colors, fonts, layout
- Company name and logo
- Fields displayed
- Additional sections

### Change Payment Methods
Edit `MembershipPaymentPage` to add more payment options:
- Card payment
- Bank transfer
- Other methods

### Change Filter Options
Edit `ReceiptHistoryPage` `_filterType` variable to add:
- Date range filters
- Amount filters
- Status filters

## Testing Checklist

- [ ] PDF generates without errors
- [ ] PDF uploads to Firebase Storage
- [ ] Receipt data saves to Firestore
- [ ] Receipt history loads correctly
- [ ] Filtering works
- [ ] Download opens PDF
- [ ] Payment confirmation creates receipt
- [ ] User status updates after payment
- [ ] Multiple receipts display correctly
- [ ] Receipt details modal works
- [ ] Error messages display properly

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| PDF not generating | Check `path_provider` is initialized |
| Upload fails | Check Firebase Storage rules and permissions |
| Receipt history empty | Verify Firestore has receipt documents |
| Download not working | Check PDF URL is valid and `url_launcher` configured |
| Status not updating | Check Firestore rules allow write access |

## Performance Tips

1. **Lazy load** receipt list with pagination
2. **Cache** receipt list in memory
3. **Compress** PDF files before upload
4. **Use streams** for real-time receipt updates
5. **Implement** offline receipt viewing

## Next Features to Add

- [ ] Email receipt delivery
- [ ] Receipt sharing
- [ ] Digital signatures
- [ ] Print receipt
- [ ] Refund receipt
- [ ] Invoice generation
- [ ] Multi-language support
- [ ] Receipt search
- [ ] Bulk download
