import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_customer/theme.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:frontend_customer/widgets/inventory_card.dart';
import 'package:http/http.dart' as http;

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _inventory = [];
  String? _errorMessage;

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/inventory/forSell");
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
        final List<dynamic> data = decoded['data']?['data'] ?? [];

        setState(() {
          _inventory = List<Map<String, dynamic>>.from(data);
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
        _errorMessage = 'Error fetching Market';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 Filter Market by search query
    final filteredMarket = _inventory
        .where((item) => item['cropName']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Market')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // 🔎 Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search crops by name...',
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.primary),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),

                    // 📋 Market List
                    Expanded(
                      child: filteredMarket.isEmpty
                          ? const Center(
                              child: Text(
                                'You have no crops in Market yet.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredMarket.length,
                              itemBuilder: (context, index) {
                                final item = filteredMarket[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: InventoryCard(
                                    item: item,
                                    onManage: () {},
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
