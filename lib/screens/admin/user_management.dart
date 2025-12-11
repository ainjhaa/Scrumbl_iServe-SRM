import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Color for roles
  Color getStatusColor(String role) {
    switch (role.toLowerCase()) {
      case "admin":
        return Colors.red;
      case "committee":
        return Colors.blue;
      case "volunteer":
        return Colors.green;
      case "member":
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // Capitalize first letter
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Users"),
            Tab(text: "Membership Applications"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // -------------------- USERS TAB --------------------
          StreamBuilder<QuerySnapshot>(
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
                  final role = user['role'];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading:
                          Icon(Icons.person, size: 40, color: getStatusColor(role)),
                      title: Text(name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('membership_requests')
                            .doc(user.id)
                            .snapshots(),
                        builder: (context, memSnapshot) {
                          String memStatus = "Not Applied";

                          if (role.toLowerCase() == "member") {
                            memStatus = "Applied";
                          } else if (memSnapshot.hasData &&
                              memSnapshot.data!.exists) {
                            final data =
                                memSnapshot.data!.data() as Map<String, dynamic>;
                            memStatus = data['status'] ?? "Pending";
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Role: $role"),
                              if (role.toLowerCase() == "volunteer" ||
                                  role.toLowerCase() == "member")
                                Text("Membership Status: ${capitalize(memStatus)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple)),
                            ],
                          );
                        },
                      ),
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

          // -------------------- MEMBERSHIP APPLICATIONS TAB --------------------
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('membership_requests')
                .orderBy('uploadedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No membership applications."));
              }

              final applications = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final data = app.data() as Map<String, dynamic>;
                  final name = data['name'] ?? '';
                  final email = data['email'] ?? '';
                  final status = capitalize(data['status'] ?? 'Pending');
                  final fileName = data['fileName'] ?? '';
                  final fileUrl = data['fileUrl'] ?? '';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: $email'),
                          Text('Status: $status'),
                          if (fileName.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                Uri uri = Uri.parse(fileUrl);
                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                              child: Text(
                                'View File: $fileName',
                                style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                        ],
                      ),
                      trailing: status.toLowerCase() == 'pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(app.id)
                                        .update({'role': 'Member'});
                                    await FirebaseFirestore.instance
                                        .collection('membership_requests')
                                        .doc(app.id)
                                        .update({'status': 'Approved'});
                                    await FirebaseFirestore.instance
                                        .collection('registrations')
                                        .doc(app.id)
                                        .update({'status': 'Approved'});
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(app.id)
                                        .update({'role': 'Volunteer'});
                                    await FirebaseFirestore.instance
                                        .collection('membership_requests')
                                        .doc(app.id)
                                        .update({'status': 'Rejected'});
                                    await FirebaseFirestore.instance
                                        .collection('registrations')
                                        .doc(app.id)
                                        .update({'status': 'Rejected'});
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// -------------------- USER DETAILS PAGE --------------------
class UserDetailsPage extends StatefulWidget {
  final String userId;

  const UserDetailsPage({super.key, required this.userId});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection("users").doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          String currentStatus = data['role'];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('membership_requests')
                .doc(widget.userId)
                .snapshots(),
            builder: (context, memSnapshot) {
              String memStatus = "Not Applied";
              String fileName = "";
              String fileUrl = "";

              if (memSnapshot.hasData && memSnapshot.data!.exists) {
                final memData = memSnapshot.data!.data() as Map<String, dynamic>;
                memStatus = capitalize(memData['status'] ?? "Pending");
                fileName = memData['fileName'] ?? "";
                fileUrl = memData['fileUrl'] ?? "";
              } else if (currentStatus.toLowerCase() == "member") {
                memStatus = "Applied";
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${data['name']}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Email: ${data['email']}", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text("Role: $currentStatus", style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    if (currentStatus.toLowerCase() == "volunteer" ||
                        currentStatus.toLowerCase() == "member")
                      Text("Membership Status: $memStatus",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                    const SizedBox(height: 10),
                    if (fileName.isNotEmpty && currentStatus.toLowerCase() == "volunteer")
                      InkWell(
                        onTap: () async {
                          Uri uri = Uri.parse(fileUrl);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Text(
                          "Uploaded File: $fileName",
                          style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Change role button
                    ElevatedButton(
                      onPressed: () => _showChangeStatusDialog(
                        userId: widget.userId,
                        currentStatus: currentStatus,
                      ),
                      child: const Text("Change Role"),
                    ),
                    const SizedBox(height: 20),

                    // Approve/Reject buttons for volunteers with pending membership
                    if (currentStatus.toLowerCase() == "volunteer" &&
                        memStatus.toLowerCase() == "pending")
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userId)
                                  .update({'role': 'Member'});
                              await FirebaseFirestore.instance
                                  .collection('membership_requests')
                                  .doc(widget.userId)
                                  .update({'status': 'Approved'});
                              await FirebaseFirestore.instance
                                  .collection('registrations')
                                  .doc(widget.userId)
                                  .update({'status': 'Approved'});
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.userId)
                                  .update({'role': 'Volunteer'});
                              await FirebaseFirestore.instance
                                  .collection('membership_requests')
                                  .doc(widget.userId)
                                  .update({'status': 'Rejected'});
                              await FirebaseFirestore.instance
                                  .collection('registrations')
                                  .doc(widget.userId)
                                  .update({'status': 'Rejected'});
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (selectedStatus == null) return;
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .update({"role": selectedStatus});
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Role updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}