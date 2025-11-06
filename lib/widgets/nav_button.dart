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
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 73),
              const SizedBox(height: 15),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
