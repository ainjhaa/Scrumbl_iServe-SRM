# Program Receipts - Quick Reference Guide

## What Was Implemented

The program receipts feature enables automatic PDF receipt generation and storage after users upload payment receipts for program/event registration.

## Key Components

### 1. Receipt Generation Service
**Location:** `lib/services/receipt_generation_service.dart`
- Generates professional PDF receipts in the same format as membership receipts
- Displays: User info, payment details, program details, amount, status

### 2. Program Receipt Service
**Location:** `lib/services/program_receipt_service.dart`
- Orchestrates receipt generation, PDF upload, and Firestore storage
- Stores receipts in `program_receipts` collection (main storage)
- Mirrors data in user collections for quick access
- Methods:
  - `generateProgramReceipt()` - Create and store receipt
  - `getUserProgramReceipts()` - Get all program receipts for user
  - `getUserProgramReceiptsStream()` - Real-time receipt updates

### 3. Payment Flow
**Location:** `lib/screens/user/event_detail_page.dart` - `PaymentPage` class
- Enhanced to automatically generate system receipt after user uploads payment
- Fetches user email from database
- Creates Receipt object with all details
- Generates professional PDF
- Stores in Firestore multiple locations

### 4. Display & Download
**Profile Page:** `lib/screens/profile_page.dart`
- Shows last 3 program payments
- Click to view details and download PDF

**Receipt History Page:** `lib/screens/receipt_history_page.dart`
- Shows all receipts with filter tabs
- Filter: All | Membership | Program Fee
- Click receipt to download PDF

## Database Structure

### Firestore Collections

```
program_receipts/              # Main storage
  {receiptId}/                 # System-generated PDF
    - userId, userName, amount, etc.
    - receiptType: 'program_fee'
    - pdfUrl: Firebase Storage URL
    - details: { eventName, eventDate, eventLocation, ... }
  
  {eventId}/receipts/          # Organized by event
    {userId}/                  # User's receipt for this event

users/{userId}/receipts/       # User's all receipts
  {receiptId}/
    - Same data structure

receipts/                      # Global collection
  {receiptId}/
    - For admin access
```

### Firebase Storage
```
receipts/{userId}/receipt_{userId}_{timestamp}.pdf
```

## Receipt Data Model

```dart
Receipt {
  id: string,                           // Unique ID
  userId: string,
  userName: string,
  userEmail: string,
  receiptType: 'program_fee',          // Type identifier
  amount: double,                       // In RM
  paymentDate: DateTime,
  paymentMethod: 'qr_code',
  transactionId: string,                // Event ID
  status: 'completed',                  // Payment status
  details: {                            // Program-specific
    eventId: string,
    eventName: string,
    eventDate: string,
    eventLocation: string,
    uploadedReceiptUrl: string          // User's uploaded receipt
  },
  pdfUrl: string,                       // System-generated receipt URL
  generatedAt: DateTime
}
```

## User Flow

### 1. Upload Payment & Generate Receipt
```
User navigates to program → Clicks register → Payment page
→ Uploads bank transfer receipt (PDF) → Clicks submit
→ System generates receipt PDF → Stores in Firestore
→ Success notification
```

### 2. View Payment History
**From Profile Page:**
1. Open Profile
2. Scroll to "Payment History"
3. Click receipt card
4. View details + program info
5. Click "Download Receipt PDF"
6. Opens/downloads the receipt

**From Receipt History Page:**
1. Click "View All" on profile
2. Select "Program Fee" filter
3. Click receipt
4. View details
5. Download PDF

## Important Methods

### Generate Receipt
```dart
final programReceiptService = ProgramReceiptService();
final result = await programReceiptService.generateProgramReceipt(
  userId: userId,
  userName: userName,
  userEmail: userEmail,
  eventId: eventId,
  eventName: eventName,
  eventDate: eventDate,
  eventLocation: eventLocation,
  amount: 50.00,  // Program fee amount
  uploadedReceiptUrl: pdfUrl,  // User's uploaded receipt
);
// Returns: {success: true, receiptId: '...', pdfUrl: '...'}
```

### Retrieve Receipts
```dart
// Get all program receipts for user
List<Receipt> receipts = await programReceiptService
  .getUserProgramReceipts(userId);

// Stream of receipts (real-time)
Stream<List<Receipt>> receiptsStream = programReceiptService
  .getUserProgramReceiptsStream(userId);
```

### Download Receipt
```dart
// In UI (automatic in Receipt History Page)
await launchUrl(
  Uri.parse(receipt.pdfUrl),
  mode: LaunchMode.externalApplication,
);
```

## Features Overview

✅ Automatic PDF Generation
- Professional receipt with program details
- Same format as membership receipts
- Shows: amount, program name, date, location, user info

✅ Multiple Storage Locations
- `program_receipts` collection (main)
- `users/{userId}/receipts` (user-specific)
- `receipts` collection (global/admin)
- `Event/{eventId}/Receipts` (event-based)

✅ Easy Access
- Profile page: last 3 payments
- Receipt history: all payments with filters
- Filterby type: Membership or Program Fee

✅ Download Support
- One-click PDF download
- Opens in default PDF viewer
- Firebase Storage URLs

## Testing the Feature

1. **Register for a program:**
   - Go to Events/Programs
   - Click event
   - Click Register button
   - Upload a PDF receipt
   - Submit

2. **Check Profile:**
   - Go to Profile
   - Scroll to Payment History
   - Click receipt to view details
   - Download PDF

3. **Check Receipt History:**
   - From Profile, click "View All"
   - Or navigate to Receipt History page
   - Filter by "Program Fee"
   - Click receipt to view and download

4. **Verify in Firestore:**
   - Open Firebase Console
   - Check `program_receipts` collection
   - Should see receipt with receiptId as document name
   - Check `users/{userId}/receipts` for user-specific copy

## Firestore Rules (Recommended)

```javascript
match /program_receipts/{document=**} {
  allow read: if request.auth.uid == resource.data.userId ||
               request.auth.token.admin == true;
  allow create, update: if request.auth != null;
}

match /users/{userId}/receipts/{document=**} {
  allow read, write: if request.auth.uid == userId ||
                       request.auth.token.admin == true;
}
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Receipt not showing | Check program_receipts collection exists, verify permissions |
| PDF not downloading | Check Firebase Storage URLs are public, try different viewer |
| Program details missing | Ensure Event document has Name, Date, Location fields |
| User email not saving | Check users collection email field, verify field name |
| Receipt not generating | Check console logs, verify receipt service methods |

## File Changes Summary

### Modified Files
1. **lib/services/program_receipt_service.dart**
   - Enhanced to save to `program_receipts` collection
   - Added stream method for real-time updates
   - Multiple collection storage

2. **lib/screens/user/event_detail_page.dart**
   - Enhanced PaymentPage uploadPayment() method
   - Automatic user email fetch
   - Improved error handling

### Unchanged (Already Support Program Receipts)
- `lib/services/receipt_generation_service.dart` ✓
- `lib/screens/receipt_history_page.dart` ✓
- `lib/screens/profile_page.dart` ✓
- `lib/models/receipt.dart` ✓

## Next Steps (Optional Enhancements)

1. Email receipts to user's email address
2. Add receipt search/filter by date range
3. Batch download multiple receipts
4. Add receipt preview before download
5. Implement receipt verification/validation
6. Add receipt expiry management
7. Create receipt templates customization
8. Add QR code to receipt for verification

## Support Documentation

See `PROGRAM_RECEIPTS_IMPLEMENTATION.md` for detailed documentation including:
- Complete feature overview
- Database schema
- Receipt model structure
- Error handling
- Troubleshooting guide
- Future enhancements
