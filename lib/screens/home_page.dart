import 'package:demo_app/screens/auth/signup_page.dart';
import 'package:demo_app/wrapper.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final user=FirebaseAuth.instance.currentUser;

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

/*void _logoutUser() {
/// try from kerol
  await Firebase.

  // Example: clear local data or session token
  // (You can integrate FirebaseAuth.instance.signOut() here if using Firebase)

  // After logout, redirect to WelcomePage
  ///Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
}*/


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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                NavButton(
                  icon: Icons.calendar_month,
                  label: "Upcoming Programs",
                  color: Colors.blue,
                  destination: PlaceholderPage("Upcoming Program"),
                ),
                NavButton(
                  icon: Icons.track_changes,
                  label: "My Activities",
                  color: Colors.green,
                  destination: PlaceholderPage("My Activities"),
                ),
                NavButton(
                  icon: Icons.workspace_premium,
                  label: "Digital Badge",
                  color: Colors.orange,
                  destination: PlaceholderPage("Digital Badge"),),
              ],
            ),

            const SizedBox(height: 40),

            // 🔹 Information sections
            InfoSection(
              title: "Know About Gaya\nHidup Rakan Muda",
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
                  "image": "../assets/images/rakan_niaga.png"
                },
                {
                  "title": "Rakan Prihatin",
                  "image": "../assets/images/rakan_prihatin.png"
                },
                {
                  "title": "Rakan Bumi",
                  "image": "../assets/images/rakan_bumi.png"
                },
                {
                  "title": "Rakan Demokrasi",
                  "image": "../assets/images/rakan_demokrasi.png"
                },
                {
                  "title": "Rakan Aktif",
                  "image": "../assets/images/rakan_aktif.png"
                },
              ],
              /*cardWidth: 130,   // 🔧 You can tweak width
              cardHeight: 150,  // 🔧 and height for layout balance
              imageHeight: 90, */ // 🔧 adjust image size
            ),



            const SizedBox(height: 25),
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
                {"title": "New Committee Intake", "image": "../assets/images/news1.jpg"},
              ],
              cardWidth: 350,   // 🔧 You can tweak width
              cardHeight: 230,
              imageHeight: 180,
            ),
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
