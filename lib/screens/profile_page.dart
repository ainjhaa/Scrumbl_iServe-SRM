import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<DocumentSnapshot?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<DocumentSnapshot?>(
        future: getUserData(),
        builder: (context, snapshot) {
          // 🔄 Loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ No user data found
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Unable to load user data."),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 60),
                ),

                const SizedBox(height: 20),

                // Name
                Row(
                  children: [
                    const Icon(Icons.person, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["name"] ?? "No Name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                // Email
                Row(
                  children: [
                    const Icon(Icons.email, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["email"] ?? "No Email",
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                // Role
                Row(
                  children: [
                    const Icon(Icons.badge, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      data["role"] ?? "Volunteer",
                      style: const TextStyle(fontSize: 18),
                    )
                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
