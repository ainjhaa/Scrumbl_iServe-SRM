import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AdminNewsPage extends StatefulWidget {
  const AdminNewsPage({super.key});

  @override
  State<AdminNewsPage> createState() => _AdminNewsPageState();
}

class _AdminNewsPageState extends State<AdminNewsPage> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController(); // FIXED: description controller
  final TextEditingController tagsCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  String selectedTag = "Announcement";   // default dropdown selection


  File? selectedImage;
  bool isUploading = false;



  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      selectedImage = File(picked.path);
      setState(() {});
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = "news_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = FirebaseStorage.instance.ref().child("newsImages").child(fileName);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future addNews() async {
    if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title, description, and select an image")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      String imageUrl = await uploadImage(selectedImage!);

      await FirebaseFirestore.instance.collection("news").add({
        "title": titleCtrl.text,
        "image": imageUrl,
        "description": descCtrl.text,
        "timestamp": FieldValue.serverTimestamp(),
        "tag": selectedTag,               
        "location": locationCtrl.text,    // (optional)
      });

      titleCtrl.clear();
      descCtrl.clear();
      locationCtrl.clear();
      selectedImage = null;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("News added successfully"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => isUploading = false);
  }

  Future deleteNews(String id) async {
    await FirebaseFirestore.instance.collection("news").doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("News deleted"), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage News")),

      body: Column(
        children: [
          // ---------------------------
          // Create News Section
          // ---------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: "News Title"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "News Description"),
                ),

                const SizedBox(height: 10),

                // TAG DROPDOWN
                DropdownButtonFormField<String>(
                  value: selectedTag,
                  decoration: const InputDecoration(labelText: "News Category Tag"),
                  items: const [
                    DropdownMenuItem(value: "Announcement", child: Text("Announcement")),
                    DropdownMenuItem(value: "Event", child: Text("Event")),
                    DropdownMenuItem(value: "Collaboration", child: Text("Collaboration")),
                    DropdownMenuItem(value: "Achievement", child: Text("Achievement")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTag = value!;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // LOCATION (OPTIONAL)
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: "Location (optional)",
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                    ),
                    child: selectedImage == null
                        ? const Center(child: Text("Tap to select image"))
                        : Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 10),

                isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: addNews,
                        icon: const Icon(Icons.upload),
                        label: const Text("Add News"),
                      ),
              ],
            ),
          ),

          /*const Divider(),

          // ---------------------------
          // Display Existing News
          // ---------------------------
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("news")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No news available"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var news = docs[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          news["image"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(news["title"]),
                        subtitle: Text(news["description"], maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteNews(news.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),*/
        ],
      ),
    );
  }
}
