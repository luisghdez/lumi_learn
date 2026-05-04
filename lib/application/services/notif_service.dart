import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:lumi_learn_app/application/services/api_config.dart';

class NotifService {
  static String get _baseUrl => ApiConfig.origin;

  Future<void> sendFcmTokenToServer(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final idToken = await user.getIdToken();
    final response = await http.patch(
      Uri.parse('$_baseUrl/users/token'),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fcmToken": token,
      }),
    );

    if (response.statusCode == 200) {
      print("✅ FCM token sent to backend successfully");
    } else {
      print(
          "❌ Failed to send FCM token to backend. Status: ${response.statusCode}");
    }
  }
}
