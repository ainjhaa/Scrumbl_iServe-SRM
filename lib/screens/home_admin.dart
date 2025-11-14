import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/widgets/ai_chat_popup.dart';
import 'package:demo_app/widgets/info_section.dart';
import 'package:demo_app/screens/notification_page.dart';
import 'package:demo_app/screens/profile_page.dart';
/*import 'membership_page.dart';
import '../widgets/membership_card.dart';*/
import 'package:demo_app/screens/placeholder_page.dart';
import 'package:demo_app/widgets/nav_button.dart';
import 'package:url_launcher/url_launcher.dart';

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

  signout() async{
    await FirebaseAuth.instance.signOut();
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
            Text("Welcome,\nAdmin SRM UTMJB!",
              style: const TextStyle(color: Colors.black, 
                                     fontSize: 28, 
                                     fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // 🔹 Horizontal navigation buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  NavButton(
                  icon: Icons.attribution,
                  label: "User\nManagement",
                  color: Colors.blue,
                  destination: PlaceholderPage("User Management"),
                ),
                NavButton(
                  icon: Icons.track_changes,
                  label: "Activities\nManagement",
                  color: Colors.green,
                  destination: PlaceholderPage("Activities Management"),
                ),
                NavButton(
                  icon: Icons.analytics,
                  label: "Report\n",
                  color: Colors.orange,
                  destination: PlaceholderPage("Report"),),
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
