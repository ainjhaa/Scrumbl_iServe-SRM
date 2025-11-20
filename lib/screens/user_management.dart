import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});


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
class UserDetailsPage extends StatefulWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          String currentStatus = data['role'];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${data['name']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Email: ${data['email']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Status: $currentStatus", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),

                /// 🔄 CHANGE STATUS BUTTON
                ElevatedButton(
                  onPressed: () => _showChangeStatusDialog(
                    userId: widget.userId,
                    currentStatus: currentStatus,
                  ),
                  child: const Text("Change Status"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------
  // 🔄 Dialog + Firebase Update Function
  // ----------------------------------------------
  void _showChangeStatusDialog({
    required String userId,
    required String currentStatus,
  }) {
    String? selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change User Status"),
        content: DropdownButtonFormField<String>(
          value: selectedStatus,
          items: const [
            DropdownMenuItem(value: "Admin", child: Text("Admin")),
            DropdownMenuItem(value: "Volunteer", child: Text("Volunteer")),
            DropdownMenuItem(value: "Member", child: Text("Member")),
          ],
          onChanged: (value) {
            selectedStatus = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus == null) return;

              // 🔥 Update role in Firebase
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .update({"role": selectedStatus});

              Navigator.pop(context);

              // 🔄 This will refresh the UI
              setState(() {});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Status updated successfully"),
                                        backgroundColor: Colors.green),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
