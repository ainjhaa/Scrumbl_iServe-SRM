import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'register_member.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPage();
}

class _MembershipPage extends State<MembershipPage> {
  //const _MembershipPage({super.key});

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  

  @override
Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(height: 50);
        }
      });

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Membership Program")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Become a Premium Member",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Access exclusive content, faster support, and VIP events!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            // 🔹 Membership promo card
            MembershipCard(
              title: "Join Membership!",
              subtitle: "Unlock exclusive features and more community benefits.",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterMember()),
              ),
            ),

            if (pickedFile != null)
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.blue[100],
                child: Center(child: Text(pickedFile!.name)),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Select File'),
              onPressed: selectFile,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Upload File'),
              onPressed: uploadFile,
            ),
            const SizedBox(height: 32),
            buildProgress(),
          ],
        ),
      ),
    );
  }
}
