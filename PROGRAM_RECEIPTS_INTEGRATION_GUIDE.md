# Program Receipts Feature - Integration Guide

## Overview
This guide explains how the program receipts feature integrates with your existing system and how it works end-to-end.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Profile Page          Receipt History Page    Payment Page  │
│  (View last 3)         (View all + Filter)     (Upload form) │
└──────────┬──────────────────────┬──────────────────────┬────┘
           │                      │                      │
           └──────────────────────┼──────────────────────┘
                                  │
                   ┌──────────────┴──────────────┐
                   │    Services Layer           │
                   ├─────────────────────────────┤
                   │ ReceiptUploadService        │
                   │ ProgramReceiptService       │
                   │ ReceiptGenerationService    │
                   └──────────────┬──────────────┘
                                  │
                ┌─────────────────┼──────────────────┐
                │                 │                  │
         ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
         │   Firestore  │  │   Firebase   │  │  Receipt    │
         │   Database   │  │  Storage     │  │  Model      │
         └──────────────┘  └──────────────┘  └─────────────┘
```

## Data Flow

### 1. Payment Upload Flow

```
User Starts Program Registration
  ↓
System Navigates to PaymentPage
  ├─ Shows: Program name, date, location, amount
  └─ Displays QR code for reference
  ↓
User Uploads Receipt PDF
  ├─ User selects PDF file from device
  └─ File path stored in memory
  ↓
User Clicks "Submit Payment"
  ↓
System Processes Upload:
  1. Upload user's PDF to Firebase Storage
     └─ Path: receipts/{userId}/{timestamp}.pdf
  2. Fetch event details from Firestore
     └─ Get: eventName, eventDate, eventLocation, price
  3. Fetch user email from Firestore
     └─ From users/{userId} document
  4. Create Receipt Object
     └─ Populate all receipt fields
  5. Generate System Receipt PDF
     └─ Using ReceiptGenerationService
     └─ Displays: amount, program details, user info
  6. Upload Generated Receipt to Storage
     └─ Path: receipts/{userId}/{timestamp}.pdf
  7. Store Receipt in Firestore (Multiple Locations):
     ├─ program_receipts/{receiptId}
     ├─ users/{userId}/receipts/{receiptId}
     ├─ receipts/{receiptId}
     ├─ program_receipts/{eventId}/receipts/{userId}
     └─ Event/{eventId}/Receipts/{userId}
  8. Store Payment Data in Firestore:
     ├─ Event/{eventId}/Payments/{userId}
     └─ users/{userId}/Payments/{eventId}
  9. Create Registration Record:
     └─ users/{userId}/RegisteredEvents/{eventId}
  ↓
Success Notification Shown
  ↓
User Navigated Back to Home
```

### 2. View Payment (Profile Page)

```
User Opens Profile Page
  ↓
System Initializes:
  1. Fetch user data from Firestore
  2. Initialize receipt sync
  3. Delete zero-amount membership receipts
  ↓
User Sees "Payment History" Section
  ├─ Streams all user receipts from:
  │  └─ users/{userId}/receipts
  ├─ Takes last 3 receipts
  └─ Filters out amount = 0 receipts
  ↓
System Displays Receipt Cards:
  ├─ For each receipt:
  │  ├─ Icon (card_membership or school)
  │  ├─ Type (Membership Fee or Program Fee)
  │  ├─ Date (dd/MM/yyyy)
  │  ├─ Amount (RM XX.XX)
  │  └─ Status (Completed/Pending/Failed)
  └─ "View All" button to Receipt History
  ↓
User Clicks Receipt Card
  ↓
System Shows Modal with:
  1. Receipt Details:
     ├─ Receipt ID
     ├─ Type
     ├─ Payment Date
     ├─ Payment Method
     ├─ Transaction ID
     ├─ Status
     └─ Amount
  2. Additional Information (if program receipt):
     ├─ Event ID
     ├─ Event Name
     ├─ Event Date
     ├─ Event Location
     └─ Uploaded Receipt URL (link)
  3. Action Buttons:
     ├─ "Download Receipt PDF" button
     └─ "Close" button
  ↓
User Clicks "Download Receipt PDF"
  ├─ Opens receipt.pdfUrl in external PDF viewer
  └─ User can save/print from viewer
```

### 3. View All Receipts (Receipt History Page)

```
User Clicks "View All" or navigates to Receipt History
  ↓
System Loads Receipt History Page
  ↓
Display Filter Tabs: All | Membership | Program Fee
  ↓
User Selects Filter
  ├─ Streams filtered receipts from:
  │  └─ users/{userId}/receipts
  │     where receiptType == selected filter
  └─ Filters out amount = 0
  ↓
System Displays List of Receipts:
  ├─ Streams from ReceiptUploadService
  ├─ Ordered by generatedAt (newest first)
  └─ For each receipt shows:
     ├─ Icon
     ├─ Type
     ├─ Transaction ID
     ├─ Date
     ├─ Amount
     └─ Status badge
  ↓
User Clicks Receipt
  ↓
System Shows Modal (same as Profile)
  ├─ Details section
  ├─ Additional information
  └─ Download button
  ↓
User Downloads PDF (same process)
```

## Database Collections Reference

### Primary Collection: `program_receipts`

**Purpose:** Main storage for all program receipts

**Document Structure:** `program_receipts/{receiptId}`
```
{
  id: "abc123def456",
  userId: "user_12345",
  userName: "John Doe",
  userEmail: "john@example.com",
  receiptType: "program_fee",
  amount: 50.00,
  paymentDate: Timestamp(2024-01-15 14:30:00),
  paymentMethod: "qr_code",
  transactionId: "event_789",
  status: "completed",
  details: {
    eventId: "event_789",
    eventName: "Advanced Flutter Workshop",
    eventDate: "2024-02-15",
    eventLocation: "Kuala Lumpur Convention Centre",
    uploadedReceiptUrl: "https://firebasestorage.googleapis.com/..."
  },
  pdfUrl: "https://firebasestorage.googleapis.com/receipts/user_12345/receipt_...",
  generatedAt: Timestamp(2024-01-15 14:35:00)
}
```

### Secondary Collection: `users/{userId}/receipts`

**Purpose:** User-specific access to all receipts (membership + program)

**Same structure as program_receipts**

### Supporting Collection: `program_receipts/{eventId}/receipts`

**Purpose:** Event-based organization of receipts

**Document:** `program_receipts/{eventId}/receipts/{userId}`

**Use case:** Easily query all receipts for a specific event

### Reference Collection: `Event/{eventId}/Receipts`

**Purpose:** Maintain relationship between events and receipts

**Document:** `Event/{eventId}/Receipts/{userId}`

## Service Integration Details

### ProgramReceiptService Methods

#### generateProgramReceipt()
```dart
// Orchestrates entire receipt creation
generateProgramReceipt({
  userId,           // User making payment
  userName,         // Display name
  userEmail,        // Email address
  eventId,          // Program/event ID
  eventName,        // Program name
  eventDate,        // Program date
  eventLocation,    // Program location
  amount,           // Fee amount (from program)
  uploadedReceiptUrl // User's uploaded receipt
})

// Process:
// 1. Create Receipt object
// 2. Generate PDF with ReceiptGenerationService
// 3. Upload PDF with ReceiptUploadService
// 4. Update Receipt with PDF URL
// 5. Save to Firestore (all locations)
// 6. Clean up temporary file
// 7. Return {success, receiptId, pdfUrl}
```

#### getUserProgramReceipts()
```dart
// One-time fetch (Future)
getUserProgramReceipts(userId)

// Returns: List<Receipt>
// Filters: where receiptType == 'program_fee'
// Order: by paymentDate (descending)
```

#### getUserProgramReceiptsStream()
```dart
// Real-time stream for UI updates
getUserProgramReceiptsStream(userId)

// Returns: Stream<List<Receipt>>
// Auto-updates when new receipts added
// Filters: where receiptType == 'program_fee'
// Order: by paymentDate (descending)
```

## Key Integration Points

### 1. Event Detail Page (Program Registration)
**File:** `lib/screens/user/event_detail_page.dart`

**Integration:**
- PaymentPage collects PDF from user
- Calls ProgramReceiptService.generateProgramReceipt()
- Stores payment data in Event/{eventId}/Payments
- Stores registration in users/{userId}/RegisteredEvents

**Important:** User email is fetched from users collection during upload

### 2. Receipt Model
**File:** `lib/models/receipt.dart`

**Integration:**
- Receipt.toMap() → Firestore document
- Receipt.fromMap() ← Firestore document
- Supports both membership and program_fee types
- Details field stores program-specific information

### 3. Receipt Generation
**File:** `lib/services/receipt_generation_service.dart`

**Integration:**
- generateReceiptPDF() accepts Receipt object
- Formats program details if receiptType == 'program_fee'
- Uses same professional template as membership
- Saves to app documents directory (temporary)

### 4. Receipt Upload
**File:** `lib/services/receipt_upload_service.dart`

**Integration:**
- uploadReceiptPDF() handles file upload
- saveReceiptToFirestore() stores metadata
- Stream methods for UI real-time updates
- Filters by receiptType for program_fee

### 5. UI Display
**Files:** 
- `lib/screens/profile_page.dart` → Recent payments
- `lib/screens/receipt_history_page.dart` → All payments with filters

**Integration:**
- Streams Receipt objects from service
- Displays in card format with icons
- Download via launchUrl(receipt.pdfUrl)
- Shows details in modal bottom sheet

## Error Handling Strategy

```
Try Block:
  1. Upload user PDF
     ├─ Success: Get download URL
     └─ Failure: Show "Upload failed"
  
  2. Fetch event details
     ├─ Success: Use data
     └─ Failure: Use defaults, continue
  
  3. Fetch user email
     ├─ Success: Use email
     └─ Failure: Use userName, continue
  
  4. Generate receipt PDF
     ├─ Success: Upload to Storage
     └─ Failure: Log error, show warning
  
  5. Save to Firestore
     ├─ Success: Show success notification
     └─ Failure: Show error, log details

Catch Block:
  ├─ Log full error to console
  ├─ Show user-friendly error message
  └─ Allow retry
```

## Performance Considerations

1. **Firestore Queries:**
   - Filtered by receiptType (indexed)
   - Ordered by paymentDate (indexed)
   - Use streams for real-time updates

2. **File Storage:**
   - PDFs stored in Firebase Storage (not in Firestore)
   - Download URLs cached in Receipt.pdfUrl
   - No file size limits due to external storage

3. **Collection Optimization:**
   - Multiple storage locations enable:
     - Fast user-specific queries
     - Event-based reporting
     - Admin access
   - Consider compound indexes if needed

## Testing the Integration

### Prerequisites
- User account with authentication
- Program/Event in database with: Name, Date, Location, Price
- Firebase Storage rules allow read/write
- Firestore rules allow user access

### Test Scenario 1: Complete Flow
1. User registers for program
2. Upload PDF receipt
3. Verify receipt in Firebase Console:
   - Check program_receipts/{receiptId}
   - Check users/{userId}/receipts/{receiptId}
4. Open Profile, see receipt in Payment History
5. Click receipt, verify details
6. Download PDF, verify opens correctly

### Test Scenario 2: Multiple Receipts
1. Register for 2 different programs
2. Upload receipts for both
3. Check Profile shows both (newest first)
4. Open Receipt History, filter by "Program Fee"
5. Verify both receipts appear

### Test Scenario 3: Edge Cases
1. **Zero Amount:** Program with RM0 fee
   - Receipt generated but filtered in UI
2. **Missing Email:** User without email field
   - Falls back to userName
3. **No Program Details:** Missing event fields
   - Uses defaults ("Unknown Event", "N/A")
4. **Failed Upload:** Network interruption
   - Shows error, allows retry

## Maintenance Notes

### Monitoring
- Monitor Firebase Storage usage (PDF files)
- Monitor Firestore storage (receipt documents)
- Check error logs in console

### Cleanup (Recommended)
- Periodically delete old PDFs (>1 year)
- Archive old receipt documents
- Implement document expiry policy

### Scaling
- Firestore: Consider sharding for high-volume events
- Storage: Implement automatic cleanup policies
- Compression: Consider compressing PDFs before storage

## Security Notes

### Firestore Rules (Recommended)
```javascript
match /program_receipts/{receiptId} {
  allow read: if request.auth.uid == resource.data.userId
               || request.auth.token.admin == true;
  allow create, update: if request.auth != null;
}
```

### Storage Rules (Recommended)
```javascript
match /receipts/{userId}/{document=**} {
  allow read: if request.auth.uid == userId
               || request.auth.token.admin == true;
  allow write: if request.auth.uid == userId;
}
```

## Troubleshooting Guide

| Issue | Symptom | Solution |
|-------|---------|----------|
| Receipt not saving | Not in Firestore | Check Firestore rules, verify write permissions |
| PDF not uploading | Error in console | Check Storage rules, verify file size, check network |
| User email missing | "User" in receipt | Verify users/{userId} has email field, check field name case |
| Program details missing | Shows "Unknown" | Check Event document has Name, Date, Location fields |
| Download fails | PDF won't open | Check Storage URLs are public, verify PDF generation |
| Stream not updating | Profile doesn't refresh | Check Firestore indexes exist, verify collection path |

## Future Enhancement Opportunities

1. **Email Integration:** Send receipt to user email
2. **SMS Notification:** Notify user of successful payment
3. **Receipt Preview:** Show PDF preview before download
4. **Batch Operations:** Download multiple receipts as ZIP
5. **Receipt Verification:** QR code verification system
6. **Analytics:** Track payment trends by program
7. **Reminders:** Automatic payment reminders
8. **Custom Templates:** Allow organization-specific designs
9. **Compliance:** Tax/audit receipt features
10. **Mobile:** Native app receipt printing

---

**Last Updated:** January 2026
**Version:** 1.0
**Status:** Production Ready
