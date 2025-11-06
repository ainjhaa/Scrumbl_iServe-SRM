import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';


class InfoSection extends StatelessWidget {
  final String title;
  final String linkLabel;
  final VoidCallback onLinkTap;
  final List<Map<String, String>> items;

  // Optional customization parameters
  final double cardWidth;
  final double cardHeight;
  final double imageHeight;

  const InfoSection({
    super.key,
    required this.title,
    required this.linkLabel,
    required this.onLinkTap,
    required this.items,
    this.cardWidth = 150,   // default card width
    this.cardHeight = 160,  // default height
    this.imageHeight = 100, // image area height
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Section title + "See More" link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: onLinkTap,
              child: Row(
                children: [
                  Text(
                    linkLabel,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.blueAccent),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 🔹 Horizontal scrollable cards
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final imagePath = item["image"] ?? '';
              final isNetwork = imagePath.startsWith('http');

              return Container(
                width: cardWidth,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🖼️ Image (URL or Asset)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                      child: isNetwork
                          ? Image.network(
                              imagePath,
                              height: imageHeight,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: imageHeight,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image,
                                    size: 40, color: Colors.grey),
                              ),
                            )
                          : Image.asset(
                              item["image"] ?? 'assets/images/default.jpg',
                              height: imageHeight,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                    ),

                    // 🏷️ Title below image
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        item["title"] ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
