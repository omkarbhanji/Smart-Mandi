import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // your getToken() and clearToken() functions

class BuyRequestService {
  // Make this method static so you can call without instantiating
  static Future<void> markAsSeen(
      {required int buyRequestId, required BuildContext context}) async {
    final url = Uri.parse(
        "${dotenv.env["BACKEND_URL"]}/api/buyRequest/markAsSeen/$buyRequestId");
    final token = await getToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"userType": "customer"},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Marked as seen successfully'),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
