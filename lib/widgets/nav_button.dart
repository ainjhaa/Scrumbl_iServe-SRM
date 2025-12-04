import 'package:flutter/material.dart';
import 'dart:ui';

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

class LockedNavButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const LockedNavButton({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show popup when locked
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Access Locked"),
            content:
                const Text("Join membership to unlock this feature!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // blur background
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.3), // blurred yellow box
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.yellow.shade700,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Feature icon faded + lock icon overlay
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      icon, size: 60, color: Colors.black.withOpacity(0.3), // faded icon
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(
                        Icons.lock,
                        color: Colors.red,
                        size: 35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

