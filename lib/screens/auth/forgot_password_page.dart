import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController email = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  reset() async {
  final userEmail = email.text.trim();
  debugPrint("Attempting reset for: $userEmail");
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reset link sent! Check your inbox.")),
    );
  } on FirebaseAuthException catch (e) {
    debugPrint("Error: ${e.code} — ${e.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "An error occurred")),
    );
  }
}


  //reset() async{
  //  await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password"),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'Enter email'),
            ),

            ElevatedButton(onPressed: (()=>reset()), child: Text("Send link"))
          ],
        ),
      ),
    );
  }
  /*
  // Step 1: Ask for Email
  Future<void> _showEmailDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // prevent accidental dismissal
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please enter your email to receive reset instructions."),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous page (Login)
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (email.text.isNotEmpty) {
                  Navigator.pop(context); // Close email dialog
                  _showResetPasswordDialog(); // Go to reset password popup
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter your email")),
                  );
                }
              },
              child: const Text("Next"),
            ),
          ],
        );
      },
    );
  }

  // Step 2: Reset Password Dialog
  Future<void> _showResetPasswordDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your new password below."),
              const SizedBox(height: 10),
              TextField(
                controller: newPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close this dialog
                Navigator.pop(context); // Return to Login Page
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newPass = newPassword.text.trim();
                final confirmPass = confirmPassword.text.trim();

                if (newPass.isEmpty || confirmPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                } else if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                } else {
                  Navigator.pop(context); // Close reset dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset successfully!")),
                  );
                  Navigator.pop(context); // Back to Login Page
                }
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Automatically show the first popup after page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEmailDialog();
    });
  }*/

  
}
