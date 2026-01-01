import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static Future<void> sendMemberWelcome({
    required String userId,
  }) async {
    // Fetch user name for personalization
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    final userData = userDoc.data();
    final userName = userData?["name"] ?? "User";

    await FirebaseFirestore.instance.collection("notifications").add({
      "userId": userId,
      "title": "🎉 Welcome to Membership!",
      "message":
          "Congratulations $userName! You are now officially a member. Thank you for being part of our community 💙",
      "type": "role_change",
      "targetRoute": "null", // ✅ welcome message → no action
      "createdAt": Timestamp.now(),
      "isRead": false,
    });
  }

  // 🔔 Notify all users about new news
  static Future<void> sendNewsNotification({
    required String newsTitle,
    required String tag,
  }) async {

    final usersSnapshot =
        await FirebaseFirestore.instance.collection("users").get();

    final batch = FirebaseFirestore.instance.batch();

    for (var doc in usersSnapshot.docs) {
      batch.set(
        FirebaseFirestore.instance.collection("notifications").doc(),
        {
          "userId": doc.id,
          "title": "📰 New $tag",
          "message": "A new \"$newsTitle\" has just been published. Check it out!",
          "type": "news",
          "targetRoute": "/news", // optional: redirect to news page
          "createdAt": FieldValue.serverTimestamp(),
          "isRead": false,
        },
      );
    }

    await batch.commit();
  }
}
