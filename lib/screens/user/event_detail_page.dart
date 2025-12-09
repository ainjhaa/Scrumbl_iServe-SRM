import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:demo_app/services/shared_pref.dart';

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
  String? userImage;
  bool loadingUser = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  // Fetch user info from shared preferences
  Future<void> loadUserInfo() async {
    userId = await SharedpreferenceHelper().getUserId();
    userName = await SharedpreferenceHelper().getUserName();
    userImage = await SharedpreferenceHelper().getUserImage();
    setState(() {
      loadingUser = false;
    }); // rebuild UI after loading
  }

  @override
  Widget build(BuildContext context) {
    // Wait until user info is loaded
    if (loadingUser) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
            return Center(child: CircularProgressIndicator());
          }
          
          // Check if the document exists
          if (!snapshot.data!.exists) {
            return Center(child: Text("Event not found"));
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
                Stack(children: [ image != "" ? Image.network( image, height: MediaQuery.of(context).size.height / 2, width: MediaQuery.of(context).size.width, fit: BoxFit.cover, ) : Image.asset( "images/event.jpg", height: MediaQuery.of(context).size.height / 2, width: MediaQuery.of(context).size.width, fit: BoxFit.cover, ), Container( height: MediaQuery.of(context).size.height / 2, child: Column( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ GestureDetector( onTap: () => Navigator.pop(context), child: Container( padding: EdgeInsets.all(8), margin: EdgeInsets.only(top: 40.0, left: 20.0), decoration: BoxDecoration( color: Colors.white, borderRadius: BorderRadius.circular(30), ), child: Icon(Icons.arrow_back_ios_new_outlined), ), ), Container( width: double.infinity, padding: EdgeInsets.all(20), color: Colors.black54, child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(name, style: TextStyle( color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)), Row( children: [ Icon(Icons.calendar_month, color: Colors.white), SizedBox(width: 10), Text(date, style: TextStyle( color: Colors.white, fontSize: 18)), SizedBox(width: 20), Icon(Icons.location_on_outlined, color: Colors.white), SizedBox(width: 10), Text(location, style: TextStyle( color: Colors.white, fontSize: 18)), ], ) ], ), ) ], ), ) ]), SizedBox(height: 20), Padding( padding: EdgeInsets.only(left: 20), child: Text("About Event", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), ), SizedBox(height: 10), Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Text(detail, style: TextStyle( fontSize: 17, fontWeight: FontWeight.w500)), ), SizedBox(height: 20), Padding( padding: EdgeInsets.symmetric(horizontal: 20), child: Row(children: [ Text("Tickets", style: TextStyle( fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(width: 40), Container( width: 50, decoration: BoxDecoration( border: Border.all(width: 2), borderRadius: BorderRadius.circular(10)), child: Column( children: [ GestureDetector( onTap: () => setState(() => ticket++), child: Text("+", style: TextStyle(fontSize: 25))), Text(ticket.toString(), style: TextStyle( fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xff6351ec))), GestureDetector( onTap: () { if (ticket > 1) setState(() => ticket--); }, child: Text("-", style: TextStyle(fontSize: 25))), ], ), ) ]), ), SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Text("Amount: RM$total",
                        style: TextStyle(
                            fontSize: 23,
                            color: Color(0xff6351ec),
                            fontWeight: FontWeight.bold)),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        // Pass user info to PaymentPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              eventId: widget.eventId,
                              userId: userId!,
                              userName: userName!,
                              userImage: userImage!,
                              amount: total.toString(),
                            ),
                          ),
                        );
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
  final String userImage;

  PaymentPage({
    required this.eventId,
    required this.userId,
    required this.amount,
    required this.userName,
    required this.userImage,
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

      // 🔹 Payment data map
      Map<String, dynamic> paymentData = {
        "userId": widget.userId,
        "userName": widget.userName,
        "userImage": widget.userImage,
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
          .collection("Users")
          .doc(widget.userId)
          .collection("Payments")
          .doc(widget.eventId)
          .set({
        ...paymentData,
        "eventId": widget.eventId,
      });

      setState(() => uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Receipt uploaded successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => uploading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Upload failed: $e")));
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
                "images/qrbank.jpg",
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
