import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});

  /*// Mock list of users
  final List<Map<String, String>> users = [
    {"name": "Ain Najiha", "status": "Admin"},
    {"name": "Muhammad Fikri", "status": "Volunteer"},
    {"name": "Siti Nurhafizah", "status": "Committee"},
    {"name": "John Doe", "status": "Volunteer"},
    {"name": "Aisyah", "status": "Committee"},
    {"name": "Muhammad Fikri", "status": "Volunteer"},
    {"name": "Siti Nurhafizah", "status": "Committee"},
    {"name": "John Doe", "status": "Volunteer"},
    {"name": "Aisyah", "status": "Committee"},
  ];*/

  Color getStatusColor(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        return Colors.red;
      case "committee":
        return Colors.blue;
      case "volunteer":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
      ),
      // 🔥 Real-time user list from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['name'];
              final status = user['role'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: Text(name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: $status"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserDetailsPage(userId: user.id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text("View"),
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

// ---------------------------------------------------------
// USER DETAILS PAGE
// ---------------------------------------------------------
class UserDetailsPage extends StatelessWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${data['name']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Email: ${data['email']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Status: ${data['role']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
