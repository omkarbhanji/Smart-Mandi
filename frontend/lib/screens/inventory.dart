import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/widgets/inventory_card.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
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

  String? selectedStatus;

  Future<void> _onSubmit(String status, int id) async {
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
          {"status": status},
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Status updated successfully!")),
        );
        await fetchInventory(); // refresh UI after update
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

  void _showStatusUpdateDialog(int inventoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Status"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select new status",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedStatus,
                  items: const [
                    DropdownMenuItem(
                      value: "available",
                      child: Text("Available"),
                    ),
                    DropdownMenuItem(
                      value: 'stock',
                      child: Text("Stock"),
                    ),
                    DropdownMenuItem(
                      value: "sold",
                      child: Text("Sold"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  })
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
              onPressed: () {
                if (selectedStatus != null) {
                  _onSubmit(selectedStatus!, inventoryId);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a status first.'),
                    ),
                  );
                }
              },
              child: const Text('Update'))
        ],
      ),
    );
  }

  void _onDelete(int inventoryId) async {
    final token = await getToken();
    final url =
        Uri.parse("${dotenv.env['BACKEND_URL']}/api/inventory/${inventoryId}");

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deleted successfully!")),
        );
        await fetchInventory();
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

  Future<void> fetchInventory() async {
    final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/inventory");
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
        _errorMessage = 'Error fetching inventory';
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(int inventoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
          'Are you sure you want to delete this item?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              _onDelete(inventoryId); // ✅ proceed with delete
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔍 Filter inventory by search query
    final filteredInventory = _inventory
        .where((item) => item['cropName']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Inventory')),
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

                    // 📋 Inventory List
                    Expanded(
                      child: filteredInventory.isEmpty
                          ? const Center(
                              child: Text(
                                'You have no crops in inventory yet.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredInventory.length,
                              itemBuilder: (context, index) {
                                final item = filteredInventory[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: InventoryCard(
                                    item: item,
                                    onManage: () {
                                      _showStatusUpdateDialog(
                                          item['inventoryId']);
                                    },
                                    onDelete: () {
                                      _confirmDelete(
                                        item['inventoryId'],
                                      );
                                    },
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
