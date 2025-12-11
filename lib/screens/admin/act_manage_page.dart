import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/admin/event_detail_page.dart';
import 'package:demo_app/screens/admin/upload_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/screens/admin/list_events_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  Stream<QuerySnapshot>? eventStream;

  @override
  void initState() {
    super.initState();

    // Load events in real-time
    eventStream = FirebaseFirestore.instance
        .collection('Event')
        .orderBy('Date')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activities Management"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [

              // 🔹 List Events Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListEventsPage()),
                  );
                },
                child: _menuButton(
                  iconPath: "assets/up.png",
                  title: "List\nEvents",
                ),
              ),

              const SizedBox(height: 30),

              // 🔹 Upload Event Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadEvent()),
                  );
                },
                child: _menuButton(
                  iconPath: "assets/up.png",
                  title: "Upload\nEvent",
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 Show All Upcoming Events
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Upcoming Events",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),

              _allEventsWidget(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 📌 Reusable Button Widget
  Widget _menuButton({required String iconPath, required String title}) {
    return Container(
      height: 150,
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black45, width: 2),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, height: 95, width: 95, fit: BoxFit.cover),
          const SizedBox(width: 25),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FIXED EVENT LIST SECTION
  Widget _allEventsWidget() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data.docs;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          physics: NeverScrollableScrollPhysics(), // allow outside scroll
          shrinkWrap: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];

            // Format date
            DateTime parsedDate = DateTime.parse(ds["Date"]);
            String formattedDate =
                DateFormat('MMM dd').format(parsedDate);

            // Hide past events
            if (DateTime.now().isAfter(parsedDate)) {
              return Container();
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminEventDetailPage(eventId: ds.id),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ds["Image"] != null && ds["Image"] != ""
                              ? Image.network(
                                  ds["Image"],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "images/event.jpg",
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, top: 10),
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: 5),

                  // Event Title + Price
                  Row(           
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ds["Name"],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(Icons.location_on),
                      Text(
                        ds["Location"],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
