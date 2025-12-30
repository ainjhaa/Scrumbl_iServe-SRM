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
      "createdAt": Timestamp.now(),
      "isRead": false,
    });
  }
}
