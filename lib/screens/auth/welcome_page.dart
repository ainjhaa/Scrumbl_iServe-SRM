import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2194C), Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              '../assets/images/srm_logo.png',
              height: 200,
              width: 200,
              
            ),
            const SizedBox(height: 20),
            const Text("iServe@SRM",
                style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            _buildButton(context, "Login", const LoginPage()),
            const SizedBox(height: 15),
            _buildButton(context, "Sign Up", const SignUpPage()),
            const SizedBox(height: 15),
            /*ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Google Sign-In coming soon!')));
              },
              icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
              label: const Text("Login with Google",
                  style: TextStyle(fontSize: 18, color: Colors.black87)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
