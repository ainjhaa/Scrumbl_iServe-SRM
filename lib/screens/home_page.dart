import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/ai_chat_popup.dart';
import '../widgets/info_section.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'membership_page.dart';
import 'placeholder_page.dart';
import '../widgets/membership_card.dart';
import '../widgets/nav_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user/list_events_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  signout() async{
    await FirebaseAuth.instance.signOut();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rakan Muda Dashboard'),
        centerTitle: true,
        actions: [
          // 🔔 Notification icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()));
            },
          ),

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
              currentUserName.isEmpty ? "Welcome!" : "Welcome, $currentUserName!",
              style: const TextStyle(color: Colors.black, 
                                     fontSize: 28, 
                                     fontWeight: FontWeight.bold,
                                     /*fontStyle: FontStyle.italic*/),
            ),
            const SizedBox(height: 15),
            // 🔹 Membership promo card
            MembershipCard(
              title: "Join Membership!",
              subtitle: "Unlock exclusive features and more community benefits.",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MembershipPage()),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Horizontal navigation buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 10), // optional spacing at start
                  NavButton(
                    icon: Icons.calendar_month,
                    label: "Upcoming\nPrograms",
                    color: Colors.blue,
                    destination: ListEventsPage(),
                  ),
                  SizedBox(width: 10), // 👈 spacing between buttons
                  NavButton(
                    icon: Icons.track_changes,
                    label: "My Activities\n",
                    color: Colors.green,
                    destination: PlaceholderPage("Events"),
                  ),
                  SizedBox(width: 10),
                  LockedNavButton(
                    icon: Icons.workspace_premium,
                    label: "Digital Badge\n",
                  ),
                  SizedBox(width: 10), // optional spacing at end
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

            InfoSection(
              title: "What's Up News !",
              linkLabel: "See More",
              onLinkTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PlaceholderPage("Announcements")));
              },
              items: const [
                {"title": "New Committee Intake", "image": "assets/news1.jpg"},
              ],
              cardWidth: 350,   // 🔧 You can tweak width
              cardHeight: 230,
              imageHeight: 180,
              //imageBorderRadius: 15,
            ),

            const SizedBox(height: 30),
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