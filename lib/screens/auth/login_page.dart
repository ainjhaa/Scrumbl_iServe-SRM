// login_page.dart (replace entire file)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/home_member.dart';
import 'package:demo_app/screens/membership_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../../services/auth_services.dart';
import '../home_admin.dart';
import 'twofa_page.dart';
import '../../services/shared_pref.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool loading = false;

  // MAIN login flow — uses AuthService, saves prefs, navigates
  Future<void> _login() async {
    setState(() => loading = true);

    try {
      String? role = await _authService.login(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // If login returned an exception string, show it
      if (role == null || (role != 'Admin' && role != 'Member' && role != 'User')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $role')),
        );
        setState(() => loading = false);
        return;
      }

      // Get current Firebase user (should be signed in by AuthService.login)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login succeeded but no current user found.')),
        );
        setState(() => loading = false);
        return;
      }

      final uid = currentUser.uid;

      // Try to fetch user doc from Firestore, try 'Users' then 'users' as fallback
      DocumentSnapshot userDoc;
      userDoc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (!userDoc.exists) {
        userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      }

      if (!userDoc.exists) {
        // still not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User record not found in Firestore')),
        );
        setState(() => loading = false);
        return;
      }

      // Extract safe fields (adjust keys to your Firestore fields)
      final data = userDoc.data() as Map<String, dynamic>;
      final userName = (data['Name'] ?? data['name'] ?? '') as String;
      final userEmail = (data['Email'] ?? data['email'] ?? currentUser.email ?? '') as String;
      final userImage = (data['Image'] ?? data['image'] ?? '') as String;

      // Save to SharedPreferences
      await SharedpreferenceHelper().saveUserId(uid);
      await SharedpreferenceHelper().saveUserName(userName);
      await SharedpreferenceHelper().saveUserEmail(userEmail);
      await SharedpreferenceHelper().saveUserImage(userImage);

      // Debug prints (viewable in console)
      print('Saved prefs: uid=$uid, name=$userName, email=$userEmail');

      // Navigate based on role
      if (role == 'Admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPage()));
      } else if (role == 'Member') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeMember()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  // remove the old signIn() — we use _login above
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot');
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
