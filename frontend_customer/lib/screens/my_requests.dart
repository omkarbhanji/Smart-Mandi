import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:frontend_customer/theme.dart';
import 'package:frontend_customer/widgets/request_card.dart';
import 'package:http/http.dart' as http;

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  bool showPending = true; // toggle between new and history
  List<Map<String, dynamic>> _buyRequests = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuyRequests();
  }

  Future<void> _fetchBuyRequests() async {
    final url =
        Uri.parse("${dotenv.env['BACKEND_URL']}/api/buyRequest/getForCustomer");
    final token = await getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data']['data'] ?? [];
        setState(() {
          _buyRequests = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching inventory";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingRequests =
        _buyRequests.where((req) => req['status'] == 'pending').toList();

    final historyRequests = _buyRequests
        .where(
            (req) => req['status'] == 'accepted' || req['status'] == 'rejected')
        .toList();

    final displayList = showPending ? pendingRequests : historyRequests;

    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : Column(
                    children: [
                      // 🔘 Toggle buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showPending
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                foregroundColor:
                                    showPending ? Colors.white : Colors.black,
                              ),
                              onPressed: () =>
                                  setState(() => showPending = true),
                              child: const Text("Pending"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !showPending
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                foregroundColor:
                                    !showPending ? Colors.white : Colors.black,
                              ),
                              onPressed: () =>
                                  setState(() => showPending = false),
                              child: const Text("History"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 📋 List of requests
                      Expanded(
                        child: displayList.isEmpty
                            ? Center(
                                child: Text(
                                  showPending
                                      ? "No pending requests."
                                      : "No history yet.",
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  return RequestCard(
                                    request: displayList[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
