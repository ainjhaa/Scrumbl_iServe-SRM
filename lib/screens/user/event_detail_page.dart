import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/services/program_receipt_service.dart';

class EDetailPage extends StatefulWidget {
  final String eventId;

  const EDetailPage({super.key, required this.eventId});

  @override
  State<EDetailPage> createState() => _EDetailPageState();
}

class _EDetailPageState extends State<EDetailPage> {
  int ticket = 1;
  int total = 0;

  // User info variables
  String? userId;
  String? userName;
  bool loadingUser = true;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Fetch user info from shared preferences
  // In event_detail_page.dart - Replace loadUserInfo():
Future<void> loadUserInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in first")),
      );
      Navigator.pop(context);
    }
    return;
  }
  
  userId = user.uid;
  
  // Get user name from Firestore
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    userName = userDoc['name'] ?? user.displayName ?? 'User';
  } catch (e) {
    userName = user.displayName ?? 'User';
  }
  
  await checkRegistration();
  
  setState(() {
    loadingUser = false;
  });
}

  // Check if user is already registered for this event
  Future<void> checkRegistration() async {
    if (userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("RegisteredEvents")
          .doc(widget.eventId)
          .get();
      setState(() {
        isRegistered = doc.exists;
      });
    } catch (e) {
      print("Error checking registration: $e");
    }
  }

  // ✅ Register for FREE event and generate system receipt
  Future<void> _registerFreeEventWithReceipt({
    required User user,
    required String userName,
    required String eventId,
    required String eventName,
    required String eventDate,
    required String eventLocation,
  }) async {
    try {
      // Get user email
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();
      
      final userEmail = userDoc.data()?['email'] ?? 
                        userDoc.data()?['Email'] ?? 
                        userName;

      // ✅ Create registration record
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("RegisteredEvents")
          .doc(eventId)
          .set({
        "eventId": eventId,
        "registrationDate": FieldValue.serverTimestamp(),
        "status": "registered",
        "paymentStatus": "free",
        "amount": 0,
      });

      // ✅ Create payment record for FREE event
      await FirebaseFirestore.instance
          .collection("Event")
          .doc(eventId)
          .collection("Payments")
          .doc(user.uid)
          .set({
        "userId": user.uid,
        "userName": userName,
        "userEmail": userEmail,
        "amount": "0",
        "type": "free",
        "paymentStatus": "free",
        "timestamp": FieldValue.serverTimestamp(),
      });

      // ✅ Generate and save program fee receipt for FREE event
      final programReceiptService = ProgramReceiptService();
      final receiptResult = await programReceiptService.generateProgramReceipt(
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        eventId: eventId,
        eventName: eventName,
        eventDate: eventDate,
        eventLocation: eventLocation,
        amount: 0.0, // FREE event has no fee
        uploadedReceiptUrl: '', // No uploaded receipt for free events
      );

      if (!receiptResult['success']) {
        print('Warning: Free event receipt generation had issues: ${receiptResult['error']}');
      }

      setState(() {
        isRegistered = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Successfully registered for free event! Receipt generated and saved."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error registering for free event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait until user info is loaded
    if (loadingUser) {
      return Scaffold(
        body: Align(alignment: Alignment.topLeft, child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.eventId)
        .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Align(alignment: Alignment.topLeft, child: CircularProgressIndicator());
          }
          
          // Check if the document exists
          if (!snapshot.data!.exists) {
            return Align(alignment: Alignment.topLeft, child: CircularProgressIndicator());
          }

          var data = snapshot.data!;
          String name = data["Name"];
          String image = data["Image"];
          String location = data["Location"];
          String date = data["Date"];
          String detail = data["Detail"];
          int price =
              int.parse(data["Price"].toString().replaceAll("RM", ""));

          total = price * ticket;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... Your existing event UI code ...
                Stack(children: [ 
                  image != "" ? Image.network( image, height: MediaQuery.of(context).size.height / 2, 
                                  width: MediaQuery.of(context).size.width, fit: BoxFit.cover, ) 
                              : Image.asset( "images/event.jpg", height: MediaQuery.of(context).size.height / 2, 
                                  width: MediaQuery.of(context).size.width, fit: BoxFit.cover, ), 
                  Container( 
                    height: MediaQuery.of(context).size.height / 2, 
                    child: Column( 
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                        children: [ 
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(top: 40.0, left: 20.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_outlined),
                              ),
                            ),
                          ),
                          Container( 
                            width: double.infinity, padding: EdgeInsets.all(20), color: Colors.black54, 
                            child: Column( 
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [ 
                                Text(name, style: TextStyle( color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)), 
                                Row( children: [ 
                                  Icon(Icons.calendar_month, color: Colors.white),  
                                  SizedBox(width: 5),                                 
                                  Text(date, style: TextStyle( color: Colors.white, fontSize: 18)), 
                                  SizedBox(width: 10), 
                                  Icon(Icons.location_on_outlined, color: Colors.white),   
                                  SizedBox(width: 5),                                 
                                  Expanded( child:
                                    Text(location, style: TextStyle(color: Colors.white, fontSize: 18),
                                    softWrap: true, maxLines: 2, // wrap into maximum 2 lines
                                    overflow: TextOverflow.ellipsis) ) // show "..." if too long), 
                            ], ) 
                              ], 
                            ), 
                          ) 
                        ], 
                    ), 
                  ) 
                ]), 
                SizedBox(height: 20), 

                Padding( padding: EdgeInsets.only(left: 20), 
                  child: Text("About Event", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), 
                ), 

                SizedBox(height: 10), 

                Padding( padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(detail, style: TextStyle( fontSize: 17)), 
                ), 

                SizedBox(height: 20), 
                
                Padding( padding: EdgeInsets.symmetric(horizontal: 20), 
                child: Row(
                  children: [ 
                    Text("Tickets", style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)), 
                    SizedBox(width: 40), 
                    Container( 
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      decoration: BoxDecoration( border: Border.all(width: 2), borderRadius: BorderRadius.circular(10)), 
                      child: Row( 
                        children: [ 
                          GestureDetector( 
                            onTap: () => setState(() => ticket++), 
                            child: 
                              Text("+", style: TextStyle(fontSize: 25))
                          ), 
                          SizedBox(width: 20),
                          Text(ticket.toString(), style: TextStyle( fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xff6351ec))), 
                          SizedBox(width: 20),
                          GestureDetector( 
                            onTap: () { if (ticket > 1) setState(() => ticket--); }, 
                            child: 
                              Text("-", style: TextStyle(fontSize: 25))
                          ), 
                        ], 
                      ),
                    ) 
                  ]), 
                ), 
                
                SizedBox(height: 20),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text("Amount: RM$total",
                        style: TextStyle(
                            fontSize: 23,
                            color: Color(0xff6351ec),
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    if (isRegistered)
                      Container(
                        width: 150,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text("REGISTERED",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User information not loaded. Please try again.")),
                            );
                            return;
                          }

                          // Get the actual user name from Firestore
                          String actualUserName = 'User'; // Default fallback
                          
                          try {
                            final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                              
                            if (userDoc.exists) {
                              // Get from 'name' field in Firestore
                              actualUserName = userDoc['name'] ?? 'User';
                            }
                          } catch (e) {
                            print('Error fetching user name: $e');
                            actualUserName = 'User';
                          }
    
                          // ✅ Get event details from StreamBuilder data
                          var data = snapshot.data!;
                          String eventName = data["Name"];
                          String eventDate = data["Date"];
                          String eventLocation = data["Location"];
                          int price = int.parse(data["Price"].toString().replaceAll("RM", ""));

                          // Check if it's a FREE event (RM0)
                          if (price == 0) {
                            // ✅ Register for FREE event with automatic receipt generation
                            await _registerFreeEventWithReceipt(
                              user: user,
                              userName: actualUserName,
                              eventId: widget.eventId,
                              eventName: eventName,
                              eventDate: eventDate,
                              eventLocation: eventLocation,
                            );
                            return;
                          }

                          // ✅ For PAID events, go to payment page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentPage(
                                eventId: widget.eventId,
                                userId: user.uid,
                                userName: actualUserName,
                                amount: total.toString(),
                              ),
                            ),
                          ).then((_) {
                            checkRegistration();
                          });
                        },
                        child: Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(0xff6351ec),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text("Book Now",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      )
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/// PAYMENT PAGE INSIDE SAME FILE
//////////////////////////////////////////////////////////////////////////////

class PaymentPage extends StatefulWidget {
  final String eventId;
  final String userId;
  final String amount;
  final String userName;

  PaymentPage({
    required this.eventId,
    required this.userId,
    required this.amount,
    required this.userName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? pdfFilePath;
  bool uploading = false;

  // Pick PDF from device
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfFilePath = result.files.single.path!;
      });
    }
  }

  // Upload PDF and create mirror records
  Future<void> uploadPayment() async {
    final adminSnapshot = await FirebaseFirestore.instance
      .collection("users")
      .where("role", isEqualTo: "Admin")
      .get();

    if (pdfFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload a PDF receipt")),
      );
      return;
    }

    setState(() => uploading = true);

    try {
      File pdfFile = File(pdfFilePath!);

      // 🔹 Upload PDF to Firebase Storage

      final storageRef = FirebaseStorage.instance
          .ref()
          .child("PaymentReceipts")
          .child(widget.eventId)
          .child("${widget.userId}.pdf");

      await storageRef.putFile(pdfFile);

      String pdfUrl = await storageRef.getDownloadURL();

      // 🔹 Fetch event details for receipt generation
      final eventDoc = await FirebaseFirestore.instance
          .collection("Event")
          .doc(widget.eventId)
          .get();

      final eventName = eventDoc['Name'] ?? "Unknown Event";
      final eventDate = eventDoc['Date'] ?? "N/A";
      final eventLocation = eventDoc['Location'] ?? "N/A";

      // 🔹 Fetch user email from database
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();
      
      final userEmail = userDoc.data()?['email'] ?? 
                        userDoc.data()?['Email'] ?? 
                        widget.userName;

      // 🔹 Payment data map
      Map<String, dynamic> paymentData = {
        "userId": widget.userId,
        "userName": widget.userName,
        "userEmail": userEmail,
        "amount": widget.amount,
        "receiptPdf": pdfUrl,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // 🔹 Store under Event/{eventId}/Payments/{userId}
      await FirebaseFirestore.instance
          .collection("Event")
          .doc(widget.eventId)
          .collection("Payments")
          .doc(widget.userId)
          .set(paymentData);

      // 🔹 Mirror under Users/{userId}/Payments/{eventId}
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("Payments")
          .doc(widget.eventId)
          .set({
        ...paymentData,
        "eventId": widget.eventId,
      });

      // 🔹 Create registration record in Users/{userId}/RegisteredEvents/{eventId}
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("RegisteredEvents")
          .doc(widget.eventId)
          .set({
        "eventId": widget.eventId,
        "registrationDate": FieldValue.serverTimestamp(),
        "status": "registered",
      });

      // 🔹 Generate and save program fee receipt (system-generated PDF)
      final programReceiptService = ProgramReceiptService();
      final receiptResult = await programReceiptService.generateProgramReceipt(
        userId: widget.userId,
        userName: widget.userName,
        userEmail: userEmail,
        eventId: widget.eventId,
        eventName: eventName,
        eventDate: eventDate,
        eventLocation: eventLocation,
        amount: double.parse(widget.amount),
        uploadedReceiptUrl: pdfUrl,
      );

      if (!receiptResult['success']) {
        print('Warning: Receipt generation had issues: ${receiptResult['error']}');
      }

      setState(() => uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful! Receipt generated and saved.")),
      );

      for (var admin in adminSnapshot.docs) {
       await FirebaseFirestore.instance.collection("notifications").add({
          "userId": admin.id,
          "title": "New Payment",
          "message":
              "${widget.userName} submitted a payment for event \"$eventName\".",
          "type": "payment",
          "targetRoute": "/userManagement", // ✅ redirect
          "createdAt": FieldValue.serverTimestamp(),
          "isRead": false,
        });
      }

      Navigator.pop(context);
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      print('Upload error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Upload")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Image.asset(
                "assets/qrbank.jpg",
                width: 250,
                height: 250,
              ),
            ),

            SizedBox(height: 20),

            Text(
              "Amount to Pay: RM ${widget.amount}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: pickPdf,
              icon: Icon(Icons.picture_as_pdf),
              label: Text("Upload PDF Receipt"),
            ),

            if (pdfFilePath != null)
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  "Selected: ${pdfFilePath!.split('/').last}",
                  style: TextStyle(color: Colors.green),
                ),
              ),

            Spacer(),

            uploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadPayment,
                    child: Text(
                      "Submit Payment",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
