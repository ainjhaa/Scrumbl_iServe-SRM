# Program Fee Receipt System - Implementation Guide

## Overview

The program fee receipt system enables automatic generation and storage of receipts when users register for volunteer/member programs. This system mirrors the membership receipt generation but is tailored for program-specific transactions.

## System Architecture

### 1. Receipt Generation Flow

```
User Registers for Program
    ↓
Uploads Payment Receipt (PDF)
    ↓
Event Details Retrieved from Firebase
    ↓
ProgramReceiptService.generateProgramReceipt()
    ↓
PDF Generated with Program Details
    ↓
PDF Uploaded to Firebase Storage
    ↓
Receipt Stored in Multiple Collections
    ↓
User Registration Recorded
```

### 2. Core Components

#### A. Receipt Model (`lib/models/receipt.dart`)
- **receiptType**: `'program_fee'` for program registrations
- **details**: Contains program-specific information:
  - `eventId`: Program/Event identifier
  - `eventName`: Program name
  - `eventDate`: Program date
  - `eventLocation`: Program location
  - `uploadedReceiptUrl`: User's uploaded payment receipt URL

#### B. Program Receipt Service (`lib/services/program_receipt_service.dart`)
**Key Methods:**
- `generateProgramReceipt()`: Main method to generate and save receipts
- `getUserProgramReceipts()`: Retrieve all program fee receipts for a user
- `getAllUserReceipts()`: Retrieve both membership and program receipts

#### C. Receipt Upload Service (`lib/services/receipt_upload_service.dart`)
**Responsibilities:**
- Upload PDF files to Firebase Storage
- Save receipt metadata to Firestore
- Handle receipt retrieval and filtering

#### D. Receipt Generation Service (`lib/services/receipt_generation_service.dart`)
**Features:**
- Generate PDF receipts with program details
- Support for both membership and program fee receipts
- Customizable receipt layout and content

## Firebase Collections Structure

### 1. User-Centric Storage
```
users/{userId}/receipts/{receiptId}
├── receiptType: "program_fee"
├── amount: [program fee amount]
├── paymentDate: [timestamp]
├── details:
│   ├── eventId: [event ID]
│   ├── eventName: [program name]
│   ├── eventDate: [program date]
│   ├── eventLocation: [program location]
│   └── uploadedReceiptUrl: [user's receipt URL]
└── pdfUrl: [generated receipt URL]
```

### 2. Event-Centric Storage
```
Event/{eventId}/Receipts/{userId}
└── [Receipt data including all fields above]
```

### 3. Global Admin Access
```
receipts/{receiptId}
└── [Complete receipt data]
```

### 4. Program Registration Tracking
```
users/{userId}/RegisteredEvents/{eventId}
├── registrationDate: [timestamp]
├── status: "registered"
└── paymentReceiptUrl: [user's uploaded receipt]
```

## Integration Points

### 1. Event Detail Page (`lib/screens/user/event_detail_page.dart`)
**Flow:**
```dart
// User uploads payment receipt (PDF)
↓
// Check if already registered (prevent duplicates)
↓
// Generate program receipt with event details
↓
// Store registration in RegisteredEvents
↓
// Update UI to show "REGISTERED" button
```

**Code Integration:**
```dart
// When payment uploaded:
await ProgramReceiptService.generateProgramReceipt(
  userId: userId,
  userName: userName,
  userEmail: userEmail,
  eventId: eventId,
  eventName: eventName,
  eventDate: eventDate,
  eventLocation: eventLocation,
  amount: eventPrice,
  uploadedReceiptUrl: pdfUrl,
);

// Record registration
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('RegisteredEvents')
    .doc(eventId)
    .set({
      'registrationDate': DateTime.now(),
      'status': 'registered',
      'paymentReceiptUrl': uploadedReceiptUrl,
    });
```

### 2. My Activities Page (`lib/screens/user/my_activities_page.dart`)
**Features:**
- Display all registered programs
- Show event details (name, date, location, fee)
- Display both uploaded and generated receipts
- View generated receipt in dialog
- Download receipt PDF

**Receipt Display Logic:**
```dart
// Fetch generated receipt
final receipt = await _getProgramReceipt(userId, eventId);

// Show generated receipt dialog
if (receipt != null) {
  _showGeneratedReceiptDialog(context, receipt);
}

// Show uploaded receipt dialog
if (uploadedReceiptUrl != null) {
  _showReceiptDialog(context, uploadedReceiptUrl);
}
```

### 3. Payment History Page (`lib/screens/receipt_history_page.dart`)
**Features:**
- Filter receipts by type (All, Membership, Program Fee)
- Display receipt details in cards
- Show transaction status and amount
- Download/view receipt PDFs

**Filter Implementation:**
```dart
// Filter buttons
_buildFilterButton('All', 'all')
_buildFilterButton('Membership', 'membership')
_buildFilterButton('Program Fee', 'program_fee')

// Stream based on filter
final stream = _filterType == 'all'
    ? _receiptService.getUserReceipts(userId)
    : _receiptService.getUserReceiptsByType(userId, _filterType);
```

### 4. Membership Registration (New Member)
**Automatic Receipt Generation:**
When a user registers as a new member, the system automatically generates a membership receipt:

```dart
// In membership_page.dart or similar:
await MembershipReceiptService.generateMembershipReceipt(
  userId: userId,
  userName: userName,
  userEmail: userEmail,
  membershipType: membershipType,
  amount: membershipFee,
);
```

## User Workflows

### Workflow 1: Program Registration with Receipt Generation
1. User browses available programs (future events only)
2. User selects program and views details
3. User uploads payment receipt (PDF)
4. System generates program fee receipt with:
   - Program name, date, location
   - Amount (program fee)
   - User's uploaded receipt link
5. Receipt stored in three locations (user, event, global)
6. Registration recorded in RegisteredEvents
7. "Book Now" button changes to "REGISTERED"

### Workflow 2: Viewing Receipts in My Activities
1. User navigates to "My Activities"
2. System fetches all registered programs
3. For each program:
   - Displays event details and image
   - Shows "View Generated Receipt" button (if receipt exists)
   - Shows "View Uploaded Receipt" button (if user uploaded receipt)
4. User can click buttons to:
   - View receipt details in dialog
   - Download PDF

### Workflow 3: Viewing All Receipts in Payment History
1. User navigates to "Payment Receipts" in profile
2. Filter buttons available:
   - All receipts
   - Membership fees only
   - Program fees only
3. User can:
   - View receipt details
   - Download PDF
   - Sort by date

## Database Queries

### Retrieve User's Program Receipts
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .where('receiptType', isEqualTo: 'program_fee')
    .orderBy('paymentDate', descending: true)
    .get();
```

### Check if User Registered for Program
```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('RegisteredEvents')
    .doc(eventId)
    .get();

final isRegistered = doc.exists;
```

### Get All User Receipts (Both Types)
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .orderBy('paymentDate', descending: true)
    .get();
```

## Receipt PDF Generation

### PDF Content Structure
```
┌─────────────────────────────────┐
│      PROGRAM FEE RECEIPT        │
├─────────────────────────────────┤
│                                 │
│  Receipt ID: [ID]               │
│  Date: [Date Time]              │
│  Status: [Status]               │
│                                 │
├─────────────────────────────────┤
│                                 │
│  PROGRAM DETAILS:               │
│  Program: [Event Name]          │
│  Date: [Event Date]             │
│  Location: [Event Location]     │
│                                 │
├─────────────────────────────────┤
│                                 │
│  PAYMENT INFORMATION:           │
│  Amount: RM [Amount]            │
│  Type: Program Fee              │
│  Transaction ID: [Event ID]     │
│                                 │
├─────────────────────────────────┤
│                                 │
│  User: [User Name]              │
│  Email: [User Email]            │
│                                 │
│  Status: [Payment Status]       │
│                                 │
└─────────────────────────────────┘
```

## File Storage Structure

### Firebase Storage Paths
```
receipts/
├── {userId}/
│   ├── receipt_{userId}_{timestamp}.pdf (user's uploaded receipt)
│   └── receipt_{userId}_{timestamp}.pdf (system generated receipt)
└── PaymentReceipts/
    └── {eventId}/
        └── {userId}.pdf (payment proof)
```

## Error Handling

### Common Scenarios
1. **Duplicate Registration**: Check RegisteredEvents before allowing new registration
2. **Missing Event Details**: Gracefully handle missing program information
3. **Storage Upload Failure**: Retry logic with user notification
4. **Firestore Write Failure**: Transaction rollback and error message

### Error Messages
- "You've already registered for this program"
- "Event details not found"
- "Failed to upload receipt. Please try again."
- "Failed to generate receipt"

## Testing Checklist

- [ ] User can upload payment receipt for program
- [ ] Program fee receipt is generated automatically
- [ ] Receipt stored in all three Firestore locations
- [ ] "REGISTERED" button shows after registration
- [ ] Can't register twice for same program
- [ ] My Activities displays all registered programs
- [ ] Generated receipts visible in My Activities
- [ ] Uploaded receipts visible in My Activities
- [ ] Payment history filters work correctly
- [ ] Program fee receipts appear in "Program Fee" filter
- [ ] Membership receipts unaffected by program registration
- [ ] PDF download works for both receipt types

## Dependencies

Required packages:
- `cloud_firestore: ^6.1.0`
- `firebase_storage: ^13.0.4`
- `pdf: ^3.10.6`
- `path_provider: ^2.1.1`
- `url_launcher: ^6.0.0`
- `intl: ^0.18.0`

## Performance Considerations

1. **Batch Operations**: Program receipt generation includes multiple Firestore writes
2. **Storage Cleanup**: Temporary PDF files deleted after upload
3. **Query Optimization**: Index on `receiptType` for faster filtering
4. **Caching**: My Activities page uses FutureBuilder for efficient data loading

## Security Considerations

1. **User Isolation**: Users can only access their own receipts
2. **Upload Validation**: File type validation (PDF only)
3. **PDF URLs**: Secure Firebase Storage URLs with automatic expiration
4. **Firestore Rules**: Documents scoped to authenticated users

## Future Enhancements

1. **Receipt Email**: Send generated receipt to user email
2. **Receipt Print**: Print receipt from app
3. **Batch Receipts**: Generate receipts for multiple programs
4. **Receipt Template Customization**: Admin-configurable receipt templates
5. **Payment Method Tracking**: Store actual payment method (QR, card, etc.)
6. **Receipt Search**: Full-text search across receipts

## Support & Troubleshooting

### Receipt Not Generating
- Verify event has valid price amount
- Check Firestore database rules allow writes
- Verify user is authenticated
- Check Firebase Storage permissions

### Missing Receipts in Payment History
- Verify receipt type filter is correct
- Check user ID matches in Firestore
- Verify receipts have paymentDate field

### Generated Receipt Not Showing in My Activities
- Verify receipt eventId matches registered eventId
- Check programReceiptService async operation completed
- Verify Firestore documents created successfully
