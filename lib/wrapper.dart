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

        // Not logged in
        if (!snapshot.hasData) return const LoginPage();
        final uid = snapshot.data!.uid;

        if (snapshot.hasData) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final role = data['role'];

              if (role == 'Admin') {
                return const AdminPage();
              } else if (role == 'Member') {
                return const HomeMember();
              } else {
                return const HomePage();
              }
            },
          );
            
        }else{
          return LoginPage();
        }
      },
    );
  }
  /*Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return HomePage();
          }else{
            return LoginPage();
          }
        }),
    );
  }*/
}
