import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserData {
  static Map<String, dynamic>? currentUser;
}

Future<void> saveToken(String token) async {
  print("✅" + token);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('authToken', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('authToken');
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');
}

Future<bool> checkLoginStatus() async {
  final token = await getToken();

  if (token == null) return false;

  final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/users/auth/check");

  try {
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("✅ ${data['user']}");
      UserData.currentUser = data['user'];
      return data['authenticated'] == true;
    } else {
      return false;
    }
  } catch (e) {
    print('❌ Error checking login: $e');
    return false;
  }
}
