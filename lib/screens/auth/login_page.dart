import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home_page.dart';
import '../../services/auth_service.dart';
import '../home_admin.dart';
import 'twofa_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService(); // Instance of AuthService
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  void _login() async {

    // Call login method from AuthService with user inputs

  String? result = await _authService.login(
      email: email.text,
      password: password.text,
    );

    

    // Navigate based on role or show error message
    if (result == 'Admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminPage(),
        ),
      );
    } else if (result == 'User') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login Failed: $result'), // Show error message
      ));
    }
  }

  signIn() async{
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: password.text);
  }

  void _open2FADialog() {
    showDialog(
      context: context,
      builder: (_) => TwoFAVerificationDialog(onVerified: _on2FAVerified),
    );
  }

  void _on2FAVerified() async {
    await AuthService.setLoginStatus(true);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    }
  }

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
              onPressed: (()=>signIn()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
