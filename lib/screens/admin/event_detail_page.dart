import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_event.dart';

class AdminEventDetailPage extends StatelessWidget {
  final String eventId;

  const AdminEventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Details")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Event")
            .doc(eventId)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return Center(child: Text("Event not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // TOP IMAGE
                data["Image"] != null && data["Image"] != ""
                ? Image.network(
                  data["Image"],
                  height: MediaQuery.of(context).size.height / 2,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, size: 80),
                ),

                //SizedBox(height: 20),

                // EVENT NAME
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data["Name"],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // DATE + LOCATION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month),
                      SizedBox(width: 8),
                      Text(data["Date"], style: TextStyle(fontSize: 18)),
                      SizedBox(width: 20),
                      Icon(Icons.location_on_outlined),
                      SizedBox(width: 8),
                      Text(data["Location"], style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // EVENT DETAILS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "About Event",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data["Detail"],
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ),

                SizedBox(height: 30),

                // ADMIN ACTION BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      AdminActionButton(
                        icon: Icons.people,
                        text: "View Registered Users",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisteredUsersPage(eventId: eventId),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10),

                      AdminActionButton(
                        icon: Icons.edit,
                        text: "Edit Event",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditEventPage(eventId: eventId),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 10),

                      AdminActionButton(
                        icon: Icons.delete_forever,
                        color: Colors.red,
                        text: "Delete Event",
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection("Event")
                              .doc(eventId)
                              .delete();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RegisteredUsersPage extends StatelessWidget {
  final String eventId;

  const RegisteredUsersPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registered Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Event')
            .doc(eventId)
            .collection('registrations')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No registered users yet."));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final user = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(user['name']),
                subtitle: Text(user['email']),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() onTap;
  final Color color;

  const AdminActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Icon(icon, color: Colors.white),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
