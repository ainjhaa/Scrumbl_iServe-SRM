import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; //  For date formatting
import 'package:demo_app/screens/admin/admin_news_editor_page.dart';
import 'package:demo_app/screens/admin/news_detail_page.dart'; 

class NewsListPage extends StatelessWidget {
  const NewsListPage({super.key});

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return "No date";

    DateTime date = ts.toDate();
    String day = DateFormat('EEEE').format(date); // Monday, Tuesday...
    String dateNum = DateFormat('dd MMM yyyy').format(date);

    return "$day, $dateNum";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest News"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminNewsPage()),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("news")
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No news available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var news = docs[index];
              String formattedDate = formatTimestamp(news["timestamp"]);

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,

                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to NewsDetailPage
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(
                          news: {
                            "id": news.id,        // needed for deletion
                            ...news.data(),
                          },
                        ),
                      ),
                    );
                  },

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // News Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          news["image"],
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Text Section
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              news["title"],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Date
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
