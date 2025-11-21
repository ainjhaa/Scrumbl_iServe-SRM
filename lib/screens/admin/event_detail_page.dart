import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEventDetailPage extends StatelessWidget {
  final String image, name, location, date, detail, id, category;

  const AdminEventDetailPage({
    super.key,
    required this.date,
    required this.detail,
    required this.image,
    required this.location,
    required this.name,
    required this.id,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(
                image,
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              /// EVENT OVERLAY TEXT
              Container(
                //bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black54,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_month, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.location_on_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          /// ABOUT EVENT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: 
            Text("About Event",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              detail,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),

          SizedBox(height: 30),

          /// ADMIN ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                AdminActionButton(
                  icon: Icons.people,
                  text: "View Registered Users",
                  onTap: () {
                    Navigator.pushNamed(context, "/registeredUsers");
                  },
                ),
                SizedBox(height: 10),
                AdminActionButton(
                  icon: Icons.edit,
                  text: "Edit Event",
                  onTap: () {
                    Navigator.pushNamed(context, "/editEvent");
                  },
                ),
                SizedBox(height: 10),
                AdminActionButton(
                  icon: Icons.delete_forever,
                  text: "Delete Event",
                  color: Colors.red,
                  onTap: () async {
                    // Show confirmation dialog
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Event"),
                          content: const Text("Are you sure you want to permanently delete this event?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm != true) return;

                    try {
                      await FirebaseFirestore.instance
                          .collection('Event')
                          .doc(id)   // Make sure you pass this eventId from your event details page
                          .delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Event deleted successfully"),
                          backgroundColor: Colors.red,
                        ),
                      );

                      

                      Navigator.pop(context); // Go back after deleting
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error deleting event: $e"),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    }
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() onTap;
  final Color color;

  const AdminActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: Row(
          children: [
            SizedBox(width: 16),
            Icon(icon, color: Colors.white),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
