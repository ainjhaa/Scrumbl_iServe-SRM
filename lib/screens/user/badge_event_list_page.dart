import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeEventListPage extends StatelessWidget {
  final int badgeIndex;

  const BadgeEventListPage({super.key, required this.badgeIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Badge $badgeIndex - Events"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Event")
            // You can filter events by type/category based on badgeIndex
            //.where("badgeCategory", isEqualTo: badgeIndex)
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
                  subtitle: Text(
                      "${data["Date"]} | ${data["Location"]}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to your existing event detail page
                    Navigator.pushNamed(
                      context,
                      "/eventDetail",
                      arguments: data.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
