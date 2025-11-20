import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'event_detail_page.dart';
import 'upload_event.dart';

class ListEventsPage extends StatelessWidget {
  const ListEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Events List"),
      ),

      body: Column(
        children: [

          // 🔹 Banner to upload event
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadEvent()),
              );
            },
            child: Container(
              width: double.infinity,
              color: Colors.blue.shade100,
              padding: const EdgeInsets.all(16),
              child: const Text(
                "➕ Upload New Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // 🔹 Real-time Event List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Event')
                  .orderBy('Date', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                if (events.isEmpty) {
                  return const Center(child: Text("No events available."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final data = events[index];
                    final eventName = data['Name'] ?? "Unnamed Event";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(eventName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text("Date: ${data['Date']}"),
                        trailing: ElevatedButton(
                          child: const Text("View"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  date: data['Date'],
                                  detail: data['Detail'],
                                  image: data['Image'],
                                  location: data['Location'],
                                  name: data['Name'],
                                  price: data['Price'].toString().replaceAll("RM", ""),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
