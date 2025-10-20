import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/widgets/request_card.dart';
import 'package:http/http.dart' as http;

class BuyRequests extends StatefulWidget {
  const BuyRequests({super.key});

  @override
  State<BuyRequests> createState() => _BuyRequestsPageState();
}

class _BuyRequestsPageState extends State<BuyRequests> {
  bool showNew = true; // toggle between new and history

  List<Map<String, dynamic>> _buyRequests = [];
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuyRequests();
  }

  Future<void> acceptOrReject(int buyRequestId, String status) async {
    final url = Uri.parse(
        '${dotenv.env['BACKEND_URL']}/api/buyRequest/updateStatus/$buyRequestId');

    final token = await getToken();

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"status": status},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request accepted successfully!")),
        );
        _fetchBuyRequests();
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

  Future<void> _fetchBuyRequests() async {
    final url =
        Uri.parse('${dotenv.env['BACKEND_URL']}/api/buyRequest/getForFarmer');

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
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching inventory';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateStatusOnAccept(int id) async {
    final token = await getToken();
    final url = Uri.parse(
        "${dotenv.env['BACKEND_URL']}/api/inventory/updateStatus/${id}");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(
          {"status": "sold"},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated successfully!")),
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

  @override
  Widget build(BuildContext context) {
    final newRequests =
        _buyRequests.where((r) => r['status'] == 'pending').toList();
    final historyRequests = _buyRequests
        .where((r) => r['status'] == 'accepted' || r['status'] == 'rejected')
        .toList();

    final displayList = showNew ? newRequests : historyRequests;

    return Scaffold(
      appBar: AppBar(title: const Text("Buy Requests")),
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
                                backgroundColor: showNew
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                foregroundColor:
                                    showNew ? Colors.white : Colors.black,
                              ),
                              onPressed: () => setState(() => showNew = true),
                              child: const Text("New Requests"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: !showNew
                                    ? AppColors.primary
                                    : Colors.grey[300],
                                foregroundColor:
                                    !showNew ? Colors.white : Colors.black,
                              ),
                              onPressed: () => setState(() => showNew = false),
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
                                  showNew
                                      ? "No new requests."
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
                                    acceptOrReject: acceptOrReject,
                                    updateStatusOnAccept: updateStatusOnAccept,
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
