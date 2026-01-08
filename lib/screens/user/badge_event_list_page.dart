import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BadgeEventListPage extends StatelessWidget {
  final int badgeIndex;

  final List<String> Category = [
    "Rakan Niaga", "Rakan Prihatin", "Rakan Bumi", "Rakan Demokrasi", 
    "Rakan Aktif", "Rakan Muzik", "Rakan Litar", 
     "Rakan Ekspresi", "Rakan Mahir", "Rakan Digital"
  ];

  BadgeEventListPage({super.key, required this.badgeIndex});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final String category = Category[badgeIndex - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text("$category Badge Events"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("RegisteredEvents")
            .where("attendance", isEqualTo: "attended") // or true
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final attendedDocs = userSnapshot.data!.docs;

          if (attendedDocs.isEmpty) {
            return const Center(
              child: Text("No attended events yet."),
            );
          }

          return ListView.builder(
            itemCount: attendedDocs.length,
            itemBuilder: (context, index) {
              final eventId = attendedDocs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("Event")
                    .doc(eventId)
                    .get(),
                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final eventData =
                      eventSnapshot.data!.data() as Map<String, dynamic>?;

                  if (eventData == null ||
                      eventData["Category"] != category) {
                    return const SizedBox.shrink(); // ❌ not this badge category
                  }

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                      title: Text(eventData["Name"] ?? "Unnamed Event"),
                      subtitle: Text(
                        "${eventData["Date"] ?? "N/A"} | ${eventData["Location"] ?? "N/A"}",
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}