import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge_event_list_page.dart';

class BadgePage extends StatelessWidget {
  final List<String> badgeImages = [
  "assets/rakan_niaga.png",
  "assets/rakan_prihatin.png",
  "assets/rakan_bumi.png",
  "assets/rakan_demokrasi.png",
  "assets/rakan_aktif.png",
  "assets/rakan_muzik.png",       // repeat or add new
  "assets/rakan_mahir.png",
  "assets/rakan_litar.png",
  "assets/rakan_ekspresi.png",
  "assets/rakan_digital.png",
];

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Digital Badge")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: 10, // 10 badges
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            childAspectRatio: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BadgeEventListPage(
                      badgeIndex: index + 1,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ⭐ UNIQUE IMAGE PER BOX
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          badgeImages[index],   // <-- each badge uses a different image
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // ⭐ EVENT COUNT
                    FutureBuilder<int>(
                      future: _countEvents(index + 1),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: Text("Loading...",
                                style: TextStyle(fontSize: 16)),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            "Events: ${snapshot.data}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );

          },
        ),
      ),
    );
  }

  /// Count how many events belong to this badge.
  /// You can change the rule as needed.
  Future<int> _countEvents(int badgeIndex) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Event")
        .get();

    // example rule: count all events (you may customise)
    return snap.docs.length;
  }
}
