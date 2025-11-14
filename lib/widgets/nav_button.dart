import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget destination;

  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.destination,
  });

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: 150,  // ← set desired width
    height: 150, // ← set desired height
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 60), // ← adjust icon size
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), // ← adjust text size
            ),
          ],
        ),
      ),
    ),
  );

  }
}
