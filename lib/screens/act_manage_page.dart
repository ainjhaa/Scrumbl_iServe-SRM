import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/ticket_event.dart';
import 'package:demo_app/screens/upload_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/screens/event_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)),
        child: Column(
          children: [
            Text(
              "Home Admin",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> UploadEvent()));
                      },
                      child: Container(
                        height: 150,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.black45, width: 2.0)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Image.asset(
                              "assets/up.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              "Upload\nEvents",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> TicketEvent()));
                      },
                      child: Container(
                        height: 150,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.black45, width: 2.0)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.0,
                            ),
                            Image.asset(
                              "assets/ticket.png",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: 30.0,
                            ),
                            Text(
                              "Event\nTickets",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Stream? eventStream;
  int eventnumber = 0;
  String? _currentCity, name;
  
  Widget allEvents() {
    return StreamBuilder(
        stream: eventStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];

                    if (_currentCity == ds["Location"]) {
                      eventnumber = eventnumber + 1;
                    }

                    String inputDate = ds["Date"];
                    DateTime parsedDate = DateTime.parse(inputDate);
                    String formattedDate =
                        DateFormat('MMM, dd').format(parsedDate);

                    DateTime currentDate = DateTime.now();
                    bool hasPassed = currentDate.isAfter(parsedDate);

                    return hasPassed
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                          date: ds["Date"],
                                          detail: ds["Detail"],
                                          image: ds["Image"],
                                          location: ds["Location"],
                                          name: ds["Name"],
                                          price: ds["Price"])));
                            },
                            child: Column(children: [
                              Container(
                                margin: EdgeInsets.only(right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        "images/event.jpg",
                                        height: 200,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10.0, top: 10.0),
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Center(
                                        child: Text(
                                          formattedDate,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    ds["Name"],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: Text(
                                      "\$" + ds["Price"],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Color(0xff6351ec),
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Row(children: [
                                Icon(Icons.location_on),
                                Text(
                                  ds["Location"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              ])
                            ]),
                          );
                  })
              : Container();
        });
  }
}


/*
class EventMediaModel {

  File? image;
  File? video;
  bool? isVideo;
  Uint8List? thumbnail;
  EventMediaModel({this.image, this.video, this.isVideo, this.thumbnail});

}
*/
