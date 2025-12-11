import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> news;

  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final String title = news["title"] ?? "Untitled News";
    final String description = news["description"] ?? "No description provided.";
    final String image = news["image"] ?? "";
    final String date = news["date"] ?? "";
    final String tag = news["tag"] ?? "";

    // Optional additional images
    final List<dynamic> extraImages = news["extraImages"] ?? [];

    final bool isNetwork = image.startsWith("http");

    return Scaffold(
      appBar: AppBar(
        title: const Text("News Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼 MAIN IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isNetwork
                  ? Image.network(
                      image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                  : Image.asset(
                      image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
            ),

            const SizedBox(height: 20),

            /// 🏷 TAG + DATE
            Row(
              children: [
                if (tag.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "#$tag",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                const SizedBox(width: 10),

                if (date.isNotEmpty)
                  Text(
                    date,
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            /// 📰 TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 15),

            /// 📄 DESCRIPTION
            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 25),

            /// 🖼 EXTRA IMAGES (optional)
            if (extraImages.isNotEmpty) ...[
              const Text(
                "More Images",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
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
            ],
          ],
        ),
      ),
    );
  }
}
