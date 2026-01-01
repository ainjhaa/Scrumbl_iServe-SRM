# Complete Receipt System Storage & Display Guide

## Overview
The Scrumbl iServe SRM application maintains a comprehensive two-tier receipt system for both membership fees and program fees, with automatic generation of SRM receipts and support for user-uploaded receipts.

---

## 1. User-Uploaded Program Fee Receipts Storage

### Collection Structure
When a user uploads a payment receipt for program registration, it is stored in three locations:

#### 1.1 Global Program Receipts Collection
```
program_receipts/
├── {eventId}/
│   └── payments/
│       └── {userId}/
│           ├── userId: string
│           ├── userName: string
│           ├── amount: double
│           ├── receiptPdf: string (Firebase Storage URL)
│           ├── eventId: string
│           ├── receiptType: "program_fee"
│           └── timestamp: Timestamp (server time)
```
**Purpose**: Admin access to all program payment receipts across events

#### 1.2 User Program Receipts Collection
```
users/{userId}/
└── program_receipts/
    └── {eventId}/
        ├── userId: string
        ├── amount: double
        ├── receiptPdf: string (Firebase Storage URL)
        ├── eventId: string
        ├── receiptType: "program_fee"
        └── timestamp: Timestamp
```
**Purpose**: User's personal collection of program payment proof uploads

#### 1.3 User Payments Collection (Legacy)
```
users/{userId}/
└── Payments/
    └── {eventId}/
        ├── userId: string
        ├── amount: double
        ├── receiptPdf: string (Firebase Storage URL)
        ├── eventId: string
        └── timestamp: Timestamp
```
**Purpose**: Maintains backward compatibility with existing payment tracking

#### 1.4 Event Payments Collection
```
Event/{eventId}/
└── Payments/
    └── {userId}/
        ├── userId: string
        ├── userName: string
        ├── amount: double
        ├── receiptPdf: string (Firebase Storage URL)
        └── timestamp: Timestamp
```
**Purpose**: Event-indexed payment records for quick access by program

### Firebase Storage Location
```
PaymentReceipts/
└── {eventId}/
    └── {userId}.pdf
```
**Content**: User's original uploaded PDF receipt

---

## 2. System-Generated SRM Receipts

### Generated Receipt Storage
After user uploads payment, system automatically generates SRM receipt and stores it in:

#### 2.1 User Receipts Collection
```
users/{userId}/
└── receipts/
    └── {receiptId}/
        ├── id: string (unique receipt ID)
        ├── userId: string
        ├── userName: string
        ├── userEmail: string
        ├── receiptType: "program_fee" or "membership"
        ├── amount: double (program fee or membership fee)
        ├── paymentDate: Timestamp
        ├── paymentMethod: string ("qr_code", "card", etc.)
        ├── transactionId: string (eventId for program fees)
        ├── status: "completed"
        ├── details: {
        │   ├── eventId: string
        │   ├── eventName: string
        │   ├── eventDate: string
        │   ├── eventLocation: string
        │   └── uploadedReceiptUrl: string (link to user's uploaded receipt)
        │}
        ├── pdfUrl: string (Firebase Storage URL to generated PDF)
        └── generatedAt: Timestamp
```
**Purpose**: User's personal receipt record with full details

#### 2.2 Global Receipts Collection
```
receipts/
└── {receiptId}/
    ├── [Same structure as user receipts]
```
**Purpose**: System-wide receipt index for admin and audit trails

#### 2.3 Event Receipts Collection
```
Event/{eventId}/
└── Receipts/
    └── {userId}/
        ├── [Same structure as user receipts]
```
**Purpose**: Event-indexed receipt records for quick lookup

### Firebase Storage Location for Generated PDFs
```
receipts/{userId}/
└── receipt_{userId}_{timestamp}.pdf
```
**Content**: System-generated SRM receipt PDF

---

## 3. Receipt Display in User Interface

### 3.1 Payment History Page (`lib/screens/receipt_history_page.dart`)

#### Data Source
- Fetches from: `users/{userId}/receipts/` collection
- Both membership and program_fee receipts are stored together

#### Filter Types Available
```
Filter Button → Query
├── "All" → All receipts (both membership and program_fee)
├── "Membership" → Only receiptType == 'membership'
└── "Program Fee" → Only receiptType == 'program_fee'
```

#### Display Logic
```dart
// Get receipts based on filter
final stream = _filterType == 'all'
    ? _receiptService.getUserReceipts(userId)  // All receipts
    : _receiptService.getUserReceiptsByType(userId, _filterType);  // Filtered

// Filter out zero-amount receipts
final receipts = allReceipts.where((receipt) => receipt.amount > 0).toList();
```

#### Receipt Card Display
- **Icon**: Card membership icon for membership, School icon for program
- **Label**: "Membership Fee" or "Program Fee"
- **Amount**: RM [amount] (formatted to 2 decimal places)
- **Transaction ID**: Receipt's transactionId field
- **Date**: paymentDate formatted as dd/MM/yyyy HH:mm
- **Status**: Colored badge (Green for completed, Orange for pending, Red for failed)
- **Action**: Expandable view with download button

### 3.2 My Activities Page (`lib/screens/user/my_activities_page.dart`)

#### Program Registration Display
Shows all registered programs with:
- Event image
- Event name, date, location, fee
- Registration date
- Two receipt viewing options:

**Generated Receipt Button** (Blue)
- Shows SRM-generated receipt in dialog
- Displays: Receipt ID, Amount, Payment Date, Program Details
- Download PDF link

**Uploaded Receipt Button** (Green)
- Shows user's uploaded receipt URL
- Allows opening in browser/PDF viewer
- Shows "No receipt uploaded yet" if missing

---

## 4. Receipt Generation Process

### 4.1 Program Fee Receipt Generation Flow

```
User Registers for Program
    ↓
File picker: User selects PDF receipt
    ↓
uploadPayment() called
    ↓
Upload PDF to Firebase Storage: PaymentReceipts/{eventId}/{userId}.pdf
    ↓
Get Firebase Storage download URL
    ↓
Save payment record to 3 Firestore locations:
├── program_receipts/{eventId}/payments/{userId}
├── users/{userId}/program_receipts/{eventId}
└── users/{userId}/Payments/{eventId}
    ↓
Create registration record in RegisteredEvents
    ↓
Call ProgramReceiptService.generateProgramReceipt()
    ↓
Generate PDF with program details:
├── Program name, date, location
├── Program fee amount
├── User's uploaded receipt URL
└── Receipt details
    ↓
Upload generated PDF to Firebase Storage: receipts/{userId}/receipt_{timestamp}.pdf
    ↓
Save Receipt object to 3 Firestore locations:
├── users/{userId}/receipts/{receiptId}
├── receipts/{receiptId}
└── Event/{eventId}/Receipts/{userId}
    ↓
Update UI: Show "REGISTERED" button
    ↓
Display success message
```

### 4.2 Generated Receipt PDF Format

```
┌──────────────────────────────────────┐
│       SCRUMBL iSERVE - SRM            │
│         PROGRAM FEE RECEIPT           │
├──────────────────────────────────────┤
│                                      │
│  Receipt ID: [receiptId]             │
│  Date: [paymentDate]                 │
│  Status: COMPLETED                   │
│                                      │
├──────────────────────────────────────┤
│         PROGRAM DETAILS              │
├──────────────────────────────────────┤
│                                      │
│  Program: [eventName]                │
│  Date: [eventDate]                   │
│  Location: [eventLocation]           │
│                                      │
├──────────────────────────────────────┤
│       PAYMENT INFORMATION            │
├──────────────────────────────────────┤
│                                      │
│  Amount: RM [amount]                 │
│  Transaction ID: [eventId]           │
│  Payment Method: QR Code             │
│                                      │
├──────────────────────────────────────┤
│         PARTICIPANT INFO             │
├──────────────────────────────────────┤
│                                      │
│  Name: [userName]                    │
│  Email: [userEmail]                  │
│                                      │
├──────────────────────────────────────┤
│  Uploaded Receipt: [URL]             │
│                                      │
└──────────────────────────────────────┘
```

---

## 5. Filtering and Query Examples

### 5.1 Retrieve All Program Fee Receipts for User
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .where('receiptType', isEqualTo: 'program_fee')
    .where('amount', isGreaterThan: 0)  // Filter out RM0
    .orderBy('amount')
    .orderBy('paymentDate', descending: true)
    .get();
```

### 5.2 Retrieve All Membership Receipts for User
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .where('receiptType', isEqualTo: 'membership')
    .where('amount', isGreaterThan: 0)  // Filter out RM0 templates
    .orderBy('paymentDate', descending: true)
    .get();
```

### 5.3 Retrieve All Receipts (Both Types)
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('receipts')
    .where('amount', isGreaterThan: 0)  // Exclude RM0
    .orderBy('paymentDate', descending: true)
    .get();
```

### 5.4 Get User's Program Fee Upload for Specific Event
```dart
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('program_receipts')
    .doc(eventId)
    .get();

final uploadUrl = (doc.data() as Map<String, dynamic>)['receiptPdf'];
```

### 5.5 Get All Program Payments for Event (Admin)
```dart
final snapshot = await FirebaseFirestore.instance
    .collection('program_receipts')
    .doc(eventId)
    .collection('payments')
    .get();
```

---

## 6. Data Fields Reference

### Receipt Model Fields
| Field | Type | Purpose |
|-------|------|---------|
| id | String | Unique receipt identifier |
| userId | String | User who made the payment |
| userName | String | User's display name |
| userEmail | String | User's email address |
| receiptType | String | "membership" or "program_fee" |
| amount | Double | Payment amount in RM |
| paymentDate | Timestamp | When payment was made |
| paymentMethod | String | "qr_code", "card", "transfer", etc. |
| transactionId | String | Event ID or transaction reference |
| status | String | "completed", "pending", "failed" |
| details | Map | Additional context (program details, etc.) |
| pdfUrl | String | Firebase Storage URL to receipt PDF |
| generatedAt | Timestamp | When receipt was generated |

### Payment Record Fields
| Field | Type | Purpose |
|-------|------|---------|
| userId | String | User who uploaded receipt |
| userName | String | User's name |
| amount | Double | Program fee amount |
| receiptPdf | String | Firebase Storage URL to uploaded PDF |
| eventId | String | Program/Event ID |
| timestamp | Timestamp | Server timestamp of upload |
| receiptType | String | "program_fee" (added in new structure) |

---

## 7. Key Implementation Files

| File | Purpose |
|------|---------|
| `lib/services/program_receipt_service.dart` | Generate and save program fee receipts |
| `lib/services/receipt_upload_service.dart` | Retrieve and filter receipts by type |
| `lib/services/receipt_generation_service.dart` | PDF generation for all receipt types |
| `lib/screens/receipt_history_page.dart` | Display receipts with filtering |
| `lib/screens/user/my_activities_page.dart` | Show registered programs and receipts |
| `lib/screens/user/event_detail_page.dart` | Handle program registration and upload |
| `lib/models/receipt.dart` | Receipt data model |

---

## 8. Zero-Amount Receipt Filtering

### Why Zero-Amount Receipts Exist
- Membership fee initialization creates receipts with RM0 as templates
- These are not actual completed transactions

### Filtering Implementation
```dart
// In receipt_history_page.dart
final allReceipts = snapshot.data ?? [];
final receipts = allReceipts.where((receipt) => receipt.amount > 0).toList();
```

**Applied in:**
- Payment History UI (filters before display)
- Receipt queries (optional, depends on use case)

**Display Result:**
- RM0 membership receipts: Hidden from UI
- RM0 program fee receipts: Hidden from UI
- "No receipts found" message if all are filtered out

---

## 9. Complete User Workflow

### New Member Registration
1. User registers as member → Membership receipt generated automatically (in background)
2. Membership receipt saved to `users/{userId}/receipts/` with amount set
3. Appears in Payment History under "Membership" filter

### Program Registration
1. User browses programs → Views only future events
2. Clicks "Book Now" on program → Navigates to Payment Upload screen
3. Selects PDF receipt file → Uploads to Firebase Storage
4. Upload stored in 4 locations (global + 3 collections)
5. SRM receipt generated with program fee amount → Stored in 3 locations
6. "REGISTERED" button shown → Registration prevented
7. User can view:
   - In "My Activities": Both uploaded and generated receipts
   - In "Payment Receipts": Generated receipt under "Program Fee" filter

---

## 10. Verification Checklist

### Storage Verification
- [ ] User-uploaded receipt in: `program_receipts/{eventId}/payments/{userId}`
- [ ] User-uploaded receipt in: `users/{userId}/program_receipts/{eventId}`
- [ ] User-uploaded receipt in: `users/{userId}/Payments/{eventId}`
- [ ] Generated receipt in: `users/{userId}/receipts/{receiptId}`
- [ ] Generated receipt in: `receipts/{receiptId}`
- [ ] Generated receipt in: `Event/{eventId}/Receipts/{userId}`
- [ ] PDFs in Firebase Storage: `PaymentReceipts/{eventId}/{userId}.pdf`
- [ ] PDFs in Firebase Storage: `receipts/{userId}/receipt_{timestamp}.pdf`

### Display Verification
- [ ] Payment History shows both membership and program fee receipts
- [ ] Filter buttons work: All, Membership, Program Fee
- [ ] Zero-amount receipts hidden from display
- [ ] My Activities shows registered programs
- [ ] Both uploaded and generated receipts viewable in My Activities
- [ ] Receipt details display correctly with program information
- [ ] PDF download links work

### Data Integrity
- [ ] Receipt ID unique across system
- [ ] Amount correctly shows program fee, not zero
- [ ] paymentDate/generatedAt timestamps present
- [ ] receiptType correctly set to "program_fee"
- [ ] Details object contains all program information
- [ ] User email captured in receipt

---

## 11. Troubleshooting

### Issue: Generated receipts not appearing in Payment History
**Solution:**
- Verify `receiptType` field is set to "program_fee" in Firestore
- Check `amount > 0` filter isn't excluding valid receipts
- Verify receipt saved to `users/{userId}/receipts/` collection
- Check orderBy field matches database indexes

### Issue: User-uploaded receipt not saved
**Solution:**
- Verify Firebase Storage path: `PaymentReceipts/{eventId}/{userId}.pdf`
- Check Firestore write permissions for `program_receipts/` collection
- Verify `users/{userId}/program_receipts/` collection exists
- Check network connectivity and file upload status

### Issue: RM0 receipts still showing
**Solution:**
- Ensure filtering logic in `_buildReceiptsList` is active
- Check that `.where((receipt) => receipt.amount > 0)` is applied
- Verify Receipt model's `amount` field is numeric type

### Issue: Filtering by receipt type not working
**Solution:**
- Verify Firestore indexes exist for:
  - `receipts` collection: index on `receiptType` + `paymentDate`
- Check ReceiptUploadService has `getUserReceiptsByType()` method
- Verify receipt objects have `receiptType` field populated
