import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/screens/user/news_detail_page.dart';
import 'package:demo_app/screens/user/news_list_page.dart';

class NewsCarouselSection extends StatelessWidget {
  final String title;

  const NewsCarouselSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE + SEE MORE BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // SEE MORE LINK
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsListPage()),
                  );
                },
                child: const Text(
                  "See More",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // FIREBASE BUILDER: FETCH 3 LATEST NEWS
        SizedBox(
          height: 235,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("news")
                .orderBy("timestamp", descending: true)
                .limit(3)
                .snapshots(),

            builder: (context, snapshot) {
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text("No news available"),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var news = docs[index];
                  String image = news["image"];
                  String title = news["title"];

                  Timestamp ts = news["timestamp"];
                  String formattedDate = "";

                  if (ts != null) {
                    formattedDate = DateFormat("EEE, dd MMM yyyy").format(ts.toDate());
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NewsDetailPage(
                            news: {
                              "id": news.id,
                              ...news.data(),
                            },
                          ),
                        ),
                      );
                    },

                    child: Container(
                      width: 300,
                      margin: const EdgeInsets.only(left: 16, right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              image,
                              width: 300,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // TEXT CONTENT
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TITLE
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // DATE
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
        ),
      ],
    );
  }
}
