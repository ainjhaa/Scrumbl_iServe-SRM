# Program Receipts Feature Implementation

## Overview
This document outlines the complete implementation of the Program Receipts feature in the iServe-SRM platform. After users upload their payment receipts for program registration, the system automatically generates and stores formatted receipt PDFs in the Firestore database, making them accessible and downloadable from multiple locations.

## Feature Components

### 1. Receipt Generation Service
**File:** `lib/services/receipt_generation_service.dart`

The `ReceiptGenerationService` generates professional PDF receipts with:
- **Consistent Formatting**: Uses the same Maroon and Grey theme as membership receipts
- **Program Fee Details**: Displays program name, date, location, and amount
- **Header Section**: Includes RAKAN MUDA logo and platform branding
- **Receipt Information**: Receipt ID, generation date, and transaction details
- **Member Information**: User name, email, and user ID
- **Payment Details**: Receipt type, payment method, transaction ID, payment date, and status
- **Amount Display**: Prominently shows the program fee amount (RM XX.XX)
- **Additional Information**: Displays program-specific details like event name, date, and location

**Key Methods:**
- `generateReceiptPDF(Receipt receipt)`: Generates a PDF receipt from a Receipt object
- `_buildDetailRow()`: Helper to format detail rows consistently
- `_loadAssetImage()`: Loads the SRM logo from assets
- `_formatReceiptType()`: Formats receipt type labels
- `_formatPaymentMethod()`: Formats payment method labels

### 2. Program Receipt Service
**File:** `lib/services/program_receipt_service.dart`

The `ProgramReceiptService` manages the complete lifecycle of program receipts:

#### Storage Structure
Receipts are stored in multiple locations for accessibility:
1. **User Receipts Collection**: `users/{userId}/receipts/{receiptId}`
   - Primary user-specific storage
2. **Global Receipts Collection**: `receipts/{receiptId}`
   - For admin/system access
3. **Program Receipts Collection**: `program_receipts/{receiptId}`
   - Dedicated collection for program receipts (main storage)
4. **Event-based Receipts**: `program_receipts/{eventId}/receipts/{userId}`
   - Organized by event for easy access
5. **Event Collection Mirror**: `Event/{eventId}/Receipts/{userId}`
   - Secondary index for event-specific queries

#### Key Methods

##### `generateProgramReceipt()`
```dart
Future<Map<String, dynamic>> generateProgramReceipt({
  required String userId,
  required String userName,
  required String userEmail,
  required String eventId,
  required String eventName,
  required String eventDate,
  required String eventLocation,
  required double amount,
  required String uploadedReceiptUrl,
})
```
- Creates a Receipt object with program fee details
- Generates a PDF receipt using ReceiptGenerationService
- Uploads PDF to Firebase Storage
- Stores receipt data in Firestore
- Returns success status and receipt ID

##### `getUserProgramReceipts()`
- Retrieves all program fee receipts for a specific user
- Filters by receipt type: `'program_fee'`
- Returns ordered list (newest first)

##### `getUserProgramReceiptsStream()`
- Real-time stream of user's program receipts
- Useful for live UI updates
- Auto-updates when new receipts are added

### 3. Receipt Upload Service
**File:** `lib/services/receipt_upload_service.dart`

Handles receipt storage and retrieval operations:
- `uploadReceiptPDF()`: Uploads PDF files to Firebase Storage
- `saveReceiptToFirestore()`: Stores receipt metadata in Firestore
- `getUserReceipts()`: Stream of all user receipts (membership + program)
- `getUserReceiptsByType()`: Stream filtered by receipt type

### 4. Receipt Model
**File:** `lib/models/receipt.dart`

The `Receipt` class represents a receipt with:
```dart
class Receipt {
  final String id;                    // Unique receipt ID
  final String userId;                // User who made payment
  final String userName;              // User's name
  final String userEmail;             // User's email
  final String receiptType;           // 'membership' or 'program_fee'
  final double amount;                // Payment amount in RM
  final DateTime paymentDate;         // Date of payment
  final String paymentMethod;         // 'qr_code', 'card', etc.
  final String transactionId;         // Transaction/Event ID
  final String status;                // 'pending', 'completed', 'failed'
  final Map<String, dynamic>? details;// Program-specific details
  final String pdfUrl;                // URL to generated PDF
  final DateTime generatedAt;         // When receipt was generated
}
```

### 5. Payment Flow Integration
**File:** `lib/screens/user/event_detail_page.dart` - `PaymentPage` class

Enhanced payment flow:
1. User selects a program/event and clicks to register
2. Payment page displays program details and amount
3. User uploads their bank transfer receipt (PDF)
4. System:
   - Uploads user's receipt PDF to Firebase Storage
   - Fetches event details (name, date, location, price)
   - Fetches user email from database
   - Creates a Receipt object with all payment information
   - Generates a professional system receipt PDF
   - Uploads the generated receipt PDF to Firebase Storage
   - Stores payment data in multiple Firestore collections
   - Creates registration record
   - Returns success confirmation

### 6. Display and Download
#### Receipt History Page
**File:** `lib/screens/receipt_history_page.dart`

Features:
- Filter buttons: All, Membership, Program Fee
- List of all receipts with:
  - Receipt type icon (card_membership or school)
  - Receipt type label
  - Transaction ID
  - Payment date
  - Amount (RM)
  - Status badge (Completed/Pending/Failed)
- Click to view receipt details:
  - Full receipt information display
  - Additional program details (if available)
  - Download PDF button
  - Close button

#### Profile Page Payment History
**File:** `lib/screens/profile_page.dart`

Features:
- "Payment History" section showing recent payments
- Last 3 receipts displayed in card format
- View All button links to Receipt History Page
- Click payment card to see:
  - Full details
  - Additional information section
  - Download PDF button

## Firestore Database Schema

### Collections

#### `program_receipts` (Main Collection)
```
program_receipts/
  {receiptId}/
    id: string
    userId: string
    userName: string
    userEmail: string
    receiptType: 'program_fee'
    amount: number
    paymentDate: timestamp
    paymentMethod: 'qr_code'
    transactionId: string (eventId)
    status: 'completed'
    details:
      eventId: string
      eventName: string
      eventDate: string
      eventLocation: string
      uploadedReceiptUrl: string
    pdfUrl: string (Firebase Storage URL)
    generatedAt: timestamp
  
  {eventId}/
    receipts/
      {userId}/
        (same structure as above)
```

#### `users/{userId}/receipts` (User-specific)
```
users/{userId}/
  receipts/
    {receiptId}/
      (same structure)
```

#### `receipts` (Global Collection)
```
receipts/
  {receiptId}/
    (same structure)
```

#### `Event/{eventId}/Receipts` (Event-specific)
```
Event/{eventId}/
  Receipts/
    {userId}/
      (same structure)
```

## Firebase Storage Structure

```
receipts/
  {userId}/
    receipt_{userId}_{timestamp}.pdf
```

Program receipt PDFs are stored in Firebase Storage at:
- Path: `receipts/{userId}/receipt_{userId}_{timestamp}.pdf`
- Accessibility: Public URLs generated and stored in Firestore

## User Experience Flow

### 1. Payment Registration
```
User navigates to Program/Event
    ↓
Clicks "Register" button
    ↓
Taken to Payment Page
    ↓
Displays program details and amount to pay
    ↓
Selects "Upload PDF Receipt"
    ↓
Selects bank transfer receipt from device
    ↓
Clicks "Submit Payment"
    ↓
System processes:
  - Upload user's receipt to Storage
  - Generate system receipt PDF
  - Upload system receipt to Storage
  - Store all data in Firestore
  - Create registration record
    ↓
Success notification shown
```

### 2. View Payment History (Profile Page)
```
User opens Profile Page
    ↓
Sees "Payment History" section
    ↓
Last 3 receipts displayed
    ↓
User can:
  - Click receipt to view details
  - See additional information (program details)
  - Download PDF receipt
  - Click "View All" to see all receipts
```

### 3. View All Receipts (Receipt History Page)
```
User clicks "View All" or opens Receipt History
    ↓
Displays all receipts with filters
    ↓
Can filter by: All | Membership | Program Fee
    ↓
For each receipt, user can:
  - Click to view full details
  - See additional information
  - Download PDF receipt
```

## Key Features

✅ **Automatic Receipt Generation**
- System automatically generates professional receipt PDFs
- No manual intervention required

✅ **Multiple Storage Locations**
- Receipts stored in program_receipts collection
- Mirrored in user collections for quick access
- Event-based organization for reporting

✅ **Consistent Formatting**
- Same professional format as membership receipts
- Maroon and Grey theme
- Complete information display

✅ **Easy Access & Download**
- Accessible from Profile Page (last 3 payments)
- Complete list in Receipt History Page
- Filterable by type (Membership/Program Fee)
- One-click PDF download

✅ **Program Fee Details**
- Displays program/event name
- Shows event date and location
- Amount prominently displayed
- Link to user-uploaded receipt

✅ **Real-time Updates**
- Stream-based receipt retrieval
- Instant updates when new receipts added
- No page refresh needed

## Testing Checklist

- [ ] User can upload payment receipt for a program
- [ ] System generates receipt PDF successfully
- [ ] Receipt PDF uploads to Firebase Storage
- [ ] Receipt data saved to program_receipts collection
- [ ] Receipt accessible in user's receipts collection
- [ ] Program receipt appears in Profile payment history
- [ ] Receipt appears in Receipt History page
- [ ] Filter works for program_fee type
- [ ] PDF downloads successfully from profile page
- [ ] PDF downloads successfully from receipt history page
- [ ] Receipt details display program information
- [ ] Additional information section shows program details
- [ ] Multiple program receipts display correctly
- [ ] Receipts sorted by date (newest first)
- [ ] No zero-amount receipts displayed
- [ ] Status badge shows correctly

## Dependencies

- `cloud_firestore`: Firebase Firestore operations
- `firebase_storage`: File storage
- `firebase_auth`: User authentication
- `intl`: Date formatting
- `path_provider`: Local file access
- `pdf`: PDF generation
- `file_picker`: File selection
- `url_launcher`: Open PDF downloads

## Error Handling

The implementation includes error handling for:
- PDF generation failures
- Firebase Storage upload failures
- Firestore save failures
- User email retrieval
- Image loading (for logo)
- PDF download failures

All errors are logged to console and appropriate user feedback provided.

## Future Enhancements

1. Email receipts to user automatically
2. Receipt search by date range
3. Receipt export in multiple formats
4. Batch receipt downloads
5. Receipt verification system
6. Payment status tracking
7. Automatic reminder for pending payments
8. Receipt printing directly from app
9. Custom receipt templates per organization
10. Receipt validation using QR codes

## Troubleshooting

### Receipt not appearing
- Check Firestore database has program_receipts collection
- Verify user has correct permissions
- Check console logs for errors

### PDF not downloading
- Verify Firebase Storage download URLs are public
- Check internet connection
- Try using different PDF viewer

### Program details not showing
- Ensure Event document has Name, Date, Location fields
- Check details object in Receipt model
- Verify receiptType is 'program_fee'

### User email not saving
- Check users collection has email field
- Verify email field name consistency (case-sensitive)
- Check Firebase rules allow read access

## Support
For issues or questions, refer to the implementation files or contact the development team.
