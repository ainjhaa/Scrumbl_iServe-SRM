import 'package:flutter/material.dart';

class RegisterMember extends StatelessWidget {
  const RegisterMember({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No new notifications')),
    );
  }
}
