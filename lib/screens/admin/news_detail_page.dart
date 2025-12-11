import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final String title = news["title"] ?? "Untitled News";
    final String description = news["description"] ?? "No description provided.";
    final String image = news["image"] ?? "";
    final String tag = news["tag"] ?? "General";
    final String location = news["location"] ?? "";
    final String id = news["id"] ?? "";

    // Convert Firebase Timestamp → Readable Date
    final timestamp = news["timestamp"];
    String formattedDate = "";

    if (timestamp != null) {
      formattedDate = DateFormat("EEE, dd MMM yyyy") //("EEE, dd MMM yyyy – hh:mm a")
          .format(timestamp.toDate());
    }

    //final List<dynamic> extraImages = news["extraImages"] ?? [];
    final bool isNetwork = image.startsWith("http");

    return Scaffold(
      appBar: AppBar(
        title: const Text("News Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmation(context, id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MAIN IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetwork
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      image,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 20),

            /// TAG + DATE + LOCATION
            Row(
              children: [
                // TAG
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "#$tag",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // DATE
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // LOCATION (optional)
            if (location.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// DESCRIPTION
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            /// EXTRA IMAGES
            /*if (extraImages.isNotEmpty) ...[
              const Text(
                "More Images",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: extraImages.length,
                  itemBuilder: (context, index) {
                    final img = extraImages[index];
                    final bool isNet = img.toString().startsWith("http");

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isNet
                            ? Image.network(
                                img,
                                width: 150,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                img,
                                width: 150,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],*/

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// CONFIRMATION DIALOG
  void _showDeleteConfirmation(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete News"),
        content: const Text("Are you sure you want to delete this news permanently?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),

          TextButton(
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteNews(context, docId);
            },
          ),
        ],
      ),
    );
  }

  /// DELETE FUNCTION
  void _deleteNews(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection("news")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("News deleted successfully")),
    );

    Navigator.pop(context); // GO BACK after deleting
  }
}