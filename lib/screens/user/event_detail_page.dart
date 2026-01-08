import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:demo_app/services/shared_pref.dart';
import 'package:demo_app/services/program_receipt_service.dart';

class EDetailPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventLocation;
  final String eventDate;
  const EDetailPage({super.key, required this.eventId, required this.eventName,required this.eventLocation,required this.eventDate});

  @override
  State<EDetailPage> createState() => _EDetailPageState();
}

class _EDetailPageState extends State<EDetailPage> {

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

  @override
  Widget build(BuildContext context) {
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
          //bool isFreeEvent = price == 0;  
        
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [ 
                  image != "" ? Image.network( 
                    image, 
                    height: MediaQuery.of(context).size.height / 2, 
                    width: MediaQuery.of(context).size.width, 
                    fit: BoxFit.cover, 
                  ) : Image.asset( 
                    "images/event.jpg", 
                    height: MediaQuery.of(context).size.height / 2, 
                    width: MediaQuery.of(context).size.width, 
                    fit: BoxFit.cover, 
                  ), 
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
                          width: double.infinity, 
                          padding: EdgeInsets.all(20), 
                          color: Colors.black54, 
                          child: Column( 
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [ 
                              Text(name, style: TextStyle( 
                                color: Colors.white, 
                                fontSize: 25, 
                                fontWeight: FontWeight.bold
                              )), 
                              Row( children: [ 
                                Icon(Icons.calendar_month, color: Colors.white),  
                                SizedBox(width: 5),                                 
                                Text(date, style: TextStyle(color: Colors.white, fontSize: 18)), 
                                SizedBox(width: 10), 
                                Icon(Icons.location_on_outlined, color: Colors.white),   
                                SizedBox(width: 5),                                 
                                Expanded( 
                                  child: Text(
                                    location, 
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                    softWrap: true, 
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis
                                  )
                                ) 
                              ], ) 
                            ], 
                          ), 
                        ) 
                      ], 
                    ), 
                  ) 
                ]), 
                SizedBox(height: 20), 

                Padding( 
                  padding: EdgeInsets.only(left: 20), 
                  child: Text("About Event", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), 
                ), 

                SizedBox(height: 10), 

                Padding( 
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(detail, style: TextStyle(fontSize: 17)), 
                ), 
                
                SizedBox(height: 20),
                
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text("Amount: RM$price",
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

                          String actualUserName = 'User';
                          
                          try {
                            final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();
                              
                            if (userDoc.exists) {
                              actualUserName = userDoc['name'] ?? 'User';
                            }
                          } catch (e) {
                            print('Error fetching user name: $e');
                            actualUserName = 'User';
                          }
                           if (price == 0) {
                            // 🆓 FREE EVENT
                            registerFreeEvent();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentPage(
                                  eventId: widget.eventId,
                                  userId: user.uid,
                                  userName: actualUserName,
                                  amount: price.toString(),
                                  eventName: name,
                                  eventDate: date,
                                  eventLocation: location,
                                  eventPrice: price.toString(),
                                ),
                              ),
                            ).then((_) {
                              checkRegistration();
                            });
                          }
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
  Future<void> registerFreeEvent() async {
    if (userId == null || userName == null) return;

    final userEventRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("RegisteredEvents")
        .doc(widget.eventId);

    final eventPaymentRef = FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.eventId)
        .collection("Payments")
        .doc(userId);

    final existing = await userEventRef.get();
    if (existing.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You are already registered")),
      );
      return;
    }

    // 🔹 Register user
    await userEventRef.set({
      "eventDate": widget.eventDate,
      "eventId": widget.eventId,
      "eventLocation": widget.eventLocation,
      "eventName": widget.eventName,
      "paymentStatus" : "free",
      "registrationDate": FieldValue.serverTimestamp(),
      "status": "registered",
    });

    // 🔹 ADD USER TO EVENT.RegisteredUsers (🔥 THIS IS THE FIX)
    final eventRef = FirebaseFirestore.instance
    .collection("Event")
    .doc(widget.eventId);

    // 🔹 ADD USER TO EVENT.RegisteredUsers (🔥 THIS IS THE FIX)
    await eventRef.update({
      "RegisteredUsers": FieldValue.arrayUnion([
        {
          "userId": userId,
          "userName": userName,
          "registrationDate": DateTime.now(),
          //"paymentType": "free",
        }
      ])
    });

    // 🔹 Optional: record as payment = FREE
    await eventPaymentRef.set({
      "userId": userId,
      "userName": userName,
      "amount": "0",
      "type": "free",
      "timestamp": FieldValue.serverTimestamp(),
    });

    setState(() {
      isRegistered = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Successfully registered 🎉"),
        backgroundColor: Colors.green,
      ),
    );
  }

}

//////////////////////////////////////////////////////////////////////////////
/// PAYMENT PAGE
//////////////////////////////////////////////////////////////////////////////

class PaymentPage extends StatefulWidget {
  final String eventId;
  final String userId;
  final String amount;
  final String userName;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String eventPrice;

  PaymentPage({
    required this.eventId,
    required this.userId,
    required this.amount,
    required this.userName,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.eventPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? pdfFilePath;
  bool uploading = false;

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

  Future<void> uploadPayment() async {
  if (pdfFilePath == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please upload a PDF receipt")),
    );
    return;
  }

  setState(() => uploading = true);

  try {
    File pdfFile = File(pdfFilePath!);

    // 1. Upload PDF to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child("PaymentReceipts")
        .child(widget.eventId)
        .child("${widget.userId}.pdf");

    await storageRef.putFile(pdfFile);
    String pdfUrl = await storageRef.getDownloadURL();

    // 2. Fetch user email
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();
    
    final userEmail = userDoc.data()?['email'] ?? 
                      userDoc.data()?['Email'] ?? 
                      widget.userName;

    // Get current timestamp for consistent use
    final timestamp = DateTime.now();

    // 3. Payment data map - use actual timestamp
    Map<String, dynamic> paymentData = {
      "userId": widget.userId,
      "userName": widget.userName,
      "userEmail": userEmail,
      "amount": widget.amount,
      "receiptPdf": pdfUrl,
      "timestamp": timestamp, // Use DateTime instead of FieldValue
      "status": "paid",
    };

    // 4. Batch write for atomic operations
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 4a. Store under Event/{eventId}/Payments/{userId} - with FieldValue for timestamp
    final paymentRef = FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.eventId)
        .collection("Payments")
        .doc(widget.userId);
    batch.set(paymentRef, {
      ...paymentData,
      "timestamp": FieldValue.serverTimestamp(), // Use FieldValue only in set()
    });

    // 4b. Mirror under Users/{userId}/Payments/{eventId}
    final userPaymentRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("Payments")
        .doc(widget.eventId);
    batch.set(userPaymentRef, {
      ...paymentData,
      "eventId": widget.eventId,
      "eventName": widget.eventName,
      "eventDate": widget.eventDate,
      "eventLocation": widget.eventLocation,
      "timestamp": FieldValue.serverTimestamp(), // Use FieldValue only in set()
    });

    // 4c. Add user to Event's RegisteredUsers array
    final eventRef = FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.eventId);
    
    // Create a map without FieldValue for arrayUnion
    Map<String, dynamic> userRegistrationData = {
      "userId": widget.userId,
      "userName": widget.userName,
      "registrationDate": timestamp, // Use DateTime for array
    };
    
    batch.update(eventRef, {
      "RegisteredUsers": FieldValue.arrayUnion([userRegistrationData])
    });

    // 4d. Add event to User's RegisteredEvents - use FieldValue in set()
    final userEventRef = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .collection("RegisteredEvents")
        .doc(widget.eventId);
    batch.set(userEventRef, {
      "eventId": widget.eventId,
      "eventName": widget.eventName,
      "eventDate": widget.eventDate,
      "eventLocation": widget.eventLocation,
      "eventPrice": widget.eventPrice,
      "registrationDate": FieldValue.serverTimestamp(), // Use FieldValue in set()
      "status": "registered",
      "paymentStatus": "paid",
    });

    // Execute batch
    await batch.commit();

    // 5. Generate and save program fee receipt
    final programReceiptService = ProgramReceiptService();
    final receiptResult = await programReceiptService.generateProgramReceipt(
      userId: widget.userId,
      userName: widget.userName,
      userEmail: userEmail,
      eventId: widget.eventId,
      eventName: widget.eventName,
      eventDate: widget.eventDate,
      eventLocation: widget.eventLocation,
      amount: double.parse(widget.amount),
      uploadedReceiptUrl: pdfUrl,
    );

    if (!receiptResult['success']) {
      print('Warning: Receipt generation had issues: ${receiptResult['error']}');
    }

    // 6. Send notifications to all admins
    final adminSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "Admin")
        .get();

    for (var admin in adminSnapshot.docs) {
      await FirebaseFirestore.instance.collection("notifications").add({
        "userId": admin.id,
        "title": "New Registration",
        "message": "${widget.userName} registered for \"${widget.eventName}\".",
        "type": "registration",
        "targetRoute": "/eventReport",
        "createdAt": FieldValue.serverTimestamp(),
        "isRead": false,
      });
    }

    setState(() => uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Registration successful! Receipt generated and saved.")),
    );

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
            // Event Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.eventName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 8),
                        Text(widget.eventDate),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16),
                        SizedBox(width: 8),
                        Text(widget.eventLocation),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

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
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Submit Payment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
