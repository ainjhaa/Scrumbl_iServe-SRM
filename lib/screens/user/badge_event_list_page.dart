import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Map badgeIndex to category string
    final String category = Category[badgeIndex - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text("Events for $category"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Event")
            .where("Category", isEqualTo: category) // filter events by category
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No events for this badge yet."),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: ListTile(
                  title: Text(data["Name"]),
                  subtitle: Text("${data["Date"]} | ${data["Location"]}"),
                  /*trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to your existing event detail page
                    Navigator.pushNamed(
                      context,
                      "/eventDetail",
                      arguments: data.id,
                    );
                  },*/
                ),
              );
            },
          );
        },
      ),

    );
  }
}