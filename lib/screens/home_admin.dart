import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/screens/admin/act_manage_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/ai_chat_popup.dart';
import 'package:demo_app/widgets/info_section.dart';
import 'package:demo_app/screens/notification_page.dart';
import 'package:demo_app/screens/profile_page.dart';

import 'package:demo_app/screens/admin/user_management.dart';
import 'package:demo_app/widgets/nav_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:demo_app/screens/admin/report_page.dart';
import 'package:demo_app/widgets/admin_news_carousel.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminState();
}

class _AdminState extends State<AdminPage> {
  void _openAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIChatPopup(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(context); // close dialog
                signout();
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // In HomePage, HomeMember, and AdminPage - Update signout() method:
  signout() async {
    try {
      // Clear SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    
      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();
    
      print('✅ Cleared SharedPreferences and signed out');
    } catch (e) {
      print('❌ Logout error: $e');
      await FirebaseAuth.instance.signOut(); // Still try to sign out
    }
  }

  String currentUserName = "";

  void getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (snapshot.exists && snapshot.data()!.containsKey("name")) {
        setState(() {
          currentUserName = snapshot["name"];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("userId", isEqualTo: user.uid)
          .where("isRead", isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = snapshot.data?.docs.length ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),

            // 🔴 RED DOT / COUNTER
            if (unreadCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? "9+" : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakan Muda Dashboard'),
        centerTitle: true,
        actions: [
          // 🔔 Notification icon
          _buildNotificationIcon(context),

          // 👤 Profile icon
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
           // 🚪 Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),

      // 🌟 Main Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [  
            Text(
              currentUserName.isEmpty ? "Welcome Admin SRM UTM JB!" : "Welcome, Admin $currentUserName!",
              style: const TextStyle(color: Colors.black, 
                                     fontSize: 28, 
                                     fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 🔹 Horizontal navigation buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  NavButton(
                  icon: Icons.attribution,
                  label: "User\nManagement",
                  color: Colors.blue,
                  destination: UserManagementPage(),
                ),
                NavButton(
                  icon: Icons.track_changes,
                  label: "Activities\nManagement",
                  color: Colors.green,
                  destination: ActivityPage(),
                ),
                NavButton(
                  icon: Icons.analytics,
                  label: "Report\n",
                  color: Colors.orange,
                  destination: ReportPage(),
                  ),
                ], // NavButtons
              ),
            ),
            

            const SizedBox(height: 30),

            // 🔹 Information sections
            InfoSection(
              title: "Know About \nGaya Hidup Rakan Muda",
              linkLabel: "See More",
              onLinkTap: () async {
                final url = Uri.parse(
                    'https://www.kbs.gov.my/pengenalan-rakanmuda/gaya-hidup.html');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $url';
                }
              },
              items: const [
                {
                  "title": "Rakan Niaga",
                  "image": "assets/rakan_niaga.png"
                },
                {
                  "title": "Rakan Prihatin",
                  "image": "assets/rakan_prihatin.png"
                },
                {
                  "title": "Rakan Bumi",
                  "image": "assets/rakan_bumi.png"
                },
                {
                  "title": "Rakan Demokrasi",
                  "image": "assets/rakan_demokrasi.png"
                },
                {
                  "title": "Rakan Aktif",
                  "image": "assets/rakan_aktif.png"
                },
              ],
              /*cardWidth: 130,   // 🔧 You can tweak width
              cardHeight: 150,  // 🔧 and height for layout balance
              imageHeight: 90, */ // 🔧 adjust image size
            ),

            const SizedBox(height: 30),

            NewsCarouselSection(title: "What's Up News!"),

            const SizedBox(height: 50),
          ],
        ),

      ),

      // 🧠 Floating AI chat button
      floatingActionButton: FloatingActionButton(
        onPressed: _openAIChat,
        backgroundColor: Colors.deepPurpleAccent,
        child: const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            'https://cdn-icons-png.flaticon.com/512/4712/4712027.png', // AI logo URL
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
