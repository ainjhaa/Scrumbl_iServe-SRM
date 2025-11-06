import 'package:flutter/material.dart';

class TwoFAVerificationDialog extends StatefulWidget {
  final VoidCallback onVerified;
  const TwoFAVerificationDialog({super.key, required this.onVerified});

  @override
  State<TwoFAVerificationDialog> createState() => _TwoFAVerificationDialogState();
}

class _TwoFAVerificationDialogState extends State<TwoFAVerificationDialog> {
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("2FA Verification"),
      content: TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Enter verification code',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onVerified();
          },
          child: const Text("Verify"),
        ),
      ],
    );
  }
}
