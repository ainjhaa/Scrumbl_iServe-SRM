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
                  .collection('events')
                  .orderBy('date', descending: false)
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
                    final eventName = data['name'] ?? "Unnamed Event";

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(eventName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text("Date: ${data['date']}"),
                        trailing: ElevatedButton(
                          child: const Text("View"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(
                                  date: data['date'],
                                  detail: data['detail'],
                                  image: data['image'],
                                  location: data['location'],
                                  name: data['name'],
                                  price: data['price'],
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
