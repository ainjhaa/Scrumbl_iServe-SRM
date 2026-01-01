import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/home_admin.dart';
import 'package:demo_app/screens/auth/login_page.dart';
import 'package:demo_app/screens/home_member.dart';
import 'package:demo_app/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not logged in
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // User is logged in
        final uid = snapshot.data!.uid;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
          builder: (context, userSnapshot) {
            // Handle loading state
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Handle error state
            if (userSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text('Error loading user data'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Check if user document exists
            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              // User document doesn't exist, redirect to home
              return const HomePage();
            }

            try {
              final data = userSnapshot.data!.data() as Map<String, dynamic>?;
              
              if (data == null) {
                return const HomePage();
              }

              final role = data['role'] as String?;

              if (role == 'Admin') {
                return const AdminPage();
              } else if (role == 'Member') {
                return const HomeMember();
              } else {
                return const HomePage();
              }
            } catch (e) {
              // Handle casting errors
              print('Error parsing user data: $e');
              return const HomePage();
            }
          },
        );
      },
    );
  }
}
