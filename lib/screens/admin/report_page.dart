import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Events Report + User Report
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reports"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.event), text: "Events Report"),
              Tab(icon: Icon(Icons.people), text: "Users Report"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventReport(),
            UserReport(),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
//                        EVENT REPORT PAGE
// ----------------------------------------------------------------------

class EventReport extends StatelessWidget {
  const EventReport({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Event").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs;

        if (events.isEmpty) {
          return const Center(child: Text("No events found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;

            final name = event["Name"] ?? "Unknown Event";
            final date = event["Date"] ?? "-";
            final location = event["Location"] ?? "-";
            final participants = event["RegisteredUsers"] ?? [];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(date),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 8),
                        Text(location),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Attendance Number
                    Text(
                      "Total Participants: ${participants.length}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),

                    const SizedBox(height: 10),

                    // Participant List
                    ExpansionTile(
                      title: const Text(
                        "View Participants",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: participants.isEmpty
                          ? [const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text("No participants registered."),
                            )]
                          : participants
                              .map<Widget>((userId) => FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(userId)
                                        .get(),
                                    builder: (context, userSnap) {
                                      if (!userSnap.hasData) {
                                        return const ListTile(
                                            title: Text("Loading..."));
                                      }

                                      final userData =
                                          userSnap.data!.data() ??
                                              {"name": "Unknown"};

                                      return ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(userData["name"]),
                                      );
                                    },
                                  ))
                              .toList(),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------------------
//                        USER REPORT PAGE
// ----------------------------------------------------------------------

class UserReport extends StatelessWidget {
  const UserReport({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .orderBy("badges", descending: true)
          .snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text(
              "Top Badge Collectors",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Show Top 3
            ...users.take(3).map((user) {
              final data = user.data() as Map<String, dynamic>;

              return Card(
                color: Colors.yellow.shade100,
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(data["name"] ?? "Unknown"),
                  subtitle: Text("Badges: ${data["badges"] ?? 0}"),
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              "All Members",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // List all users
            ...users.map((user) {
              final data = user.data() as Map<String, dynamic>;

              return Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data["name"] ?? "Unknown User"),
                  subtitle: Text("Badges collected: ${data["badges"] ?? 0}"),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
