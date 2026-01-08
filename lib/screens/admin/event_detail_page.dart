import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

                SizedBox(height: 10),

                // EVENT NAME
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data["Name"],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // DATE + LOCATION
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month),
                      SizedBox(width: 8),
                      Text(data["Date"], style: TextStyle(fontSize: 16)),
                      SizedBox(width: 20),
                      Icon(Icons.location_on_outlined),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data["Location"],
                          style: TextStyle(fontSize: 16),
                          maxLines: 3, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // EVENT DETAILS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "About Event",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data["Detail"],
                    style: TextStyle(fontSize: 16, color: Colors.black87),
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
                SizedBox(height: 100),
              ],
            ),
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

class RegisteredUsersPage extends StatelessWidget {
  final String eventId;

  const RegisteredUsersPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registered Users")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Event')
            .doc(eventId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Event not found"));
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          final List registeredUsers = eventData["RegisteredUsers"] ?? [];

          if (registeredUsers.isEmpty) {
            return const Center(child: Text("No registered users yet."));
          }

          return ListView.builder(
            itemCount: registeredUsers.length,
            itemBuilder: (context, index) {
              final user = registeredUsers[index];

              final String name = user["userName"] ?? "Unknown";
              final String userId = user["userId"] ?? "";
              final Timestamp? ts = user["registrationDate"];

              final String date = ts != null
                  ? DateFormat('dd/MM/yyyy').format(ts.toDate())
                  : "N/A";
              final String attendance = user["attendance"] ?? "pending";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: attendance == "attended"
                        ? Colors.green[100]
                        : attendance == "absent"
                            ? Colors.red[100]
                            : Colors.grey[200],
                    child: Icon(
                      Icons.person,
                      color: attendance == "attended"
                          ? Colors.green
                          : attendance == "absent"
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Registered: $date",
                        style: TextStyle(
                          fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        "Attendance: ${attendance.toUpperCase()}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: attendance == "attended"
                              ? Colors.green
                              : attendance == "absent"
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  // ✅ Attendance buttons
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ❌ Absent
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        style: IconButton.styleFrom(backgroundColor: Colors.red[100]),
                        tooltip: "Mark Absent",
                        onPressed: attendance == "pending" ? () async {
                          await updateAttendance(
                            eventId: eventId,
                            userId: userId,
                            status: "absent",
                          );
                        } : null,
                      ),

                      // ✔ Attended
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        style: IconButton.styleFrom(backgroundColor: Colors.green[100]),
                        tooltip: "Mark Attended",
                        onPressed: attendance == "pending" ? () async {
                          await updateAttendance(
                            eventId: eventId,
                            userId: userId,
                            status: "attended",
                          );
                        } : null,
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

  Future<void> updateAttendance({
    required String eventId,
    required String userId,
    required String status, // attended | absent
  }) async {
    final eventRef =
        FirebaseFirestore.instance.collection("Event").doc(eventId);

    final snapshot = await eventRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final List users = List.from(data["RegisteredUsers"] ?? []);

    for (int i = 0; i < users.length; i++) {
      if (users[i]["userId"] == userId) {
        users[i]["attendance"] = status;
        users[i]["attendanceUpdatedAt"] = FieldValue.serverTimestamp();
        break;
      }
    }

    await eventRef.update({
      "RegisteredUsers": users,
    });

    await FirebaseFirestore.instance
    .collection("users")
    .doc(userId)
    .collection("RegisteredEvents")
    .doc(eventId)
    .update({
  "attendance": status, // attended | absent
});
  }
}