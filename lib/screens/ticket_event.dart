import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/services/database.dart';
import 'package:flutter/material.dart';

class TicketEvent extends StatefulWidget {
  const TicketEvent({super.key});

  @override
  State<TicketEvent> createState() => _TicketEventState();
}

class _TicketEventState extends State<TicketEvent> {
  Stream? ticketStream;

ontheload()async{
  ticketStream= await DatabaseMethods().getTickets();
  setState(() {
    
  });
}  

@override
  void initState() {
    ontheload();
    super.initState();
  }

  Widget allTickets() {
    return StreamBuilder(
        stream: ticketStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return Container(
                      margin: EdgeInsets.only(left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black38, width: 2.0),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                ds["Location"],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Divider(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                    ds["Image"],
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    )),
                                SizedBox(
                                  width: 20.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ds["Event"],
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 19.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          ds["Date"],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                     SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          ds["Name"],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.group,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          ds["Number"],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 19.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Icon(
                                          Icons.monetization_on,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          "\$" + ds["Total"],
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  })
              : Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 10.0, top: 40.0),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new_outlined)),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 4.0,
                ),
                Text(
                  "Event Tickets",
                  style: TextStyle(
                      color: Color(0xff6351ec),
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20.0,),
            allTickets()
          ],
        ),
      ),
    );
  }
}
