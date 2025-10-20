import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_customer/screens/login.dart';
import 'package:frontend_customer/screens/market.dart';
import 'package:frontend_customer/screens/my_requests.dart';
import 'package:frontend_customer/screens/notification_page.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:frontend_customer/theme.dart';
import 'package:frontend_customer/widgets/action_button.dart';
import 'package:frontend_customer/widgets/image_slider.dart';
import 'package:frontend_customer/widgets/side_drawer.dart';
import "package:http/http.dart" as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> _notifications = [];
  String _notificationCnt = '0';

  Future<void> _getNotifications() async {
    final url = Uri.parse(
        "${dotenv.env["BACKEND_URL"]}/api/buyRequest/getCustomerNotifications");
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
        List<dynamic> data = decoded['data']['unseenRequests'];
        print(decoded);
        setState(() {
          _notificationCnt = decoded['total'].toString();
          _notifications = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("❌ Error $e");
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Cancel
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await clearToken();

              // Navigate to login and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    const customerName = 'Customer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Mandi'),
        actions: [
          // 🔔 Notification icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationPage(notifications: _notifications),
                    ),
                  ).then(
                    (_) {
                      _getNotifications();
                    },
                  );
                },
              ),
              if (int.tryParse(_notificationCnt) != null &&
                  int.tryParse(_notificationCnt)! > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(_notificationCnt),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: SideDrawer(
        showLogoutDialog: () => _showLogoutDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome Back,",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
                color: AppColors.textDark,
              ),
            ),
            const Text(
              customerName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const ImageSlider(),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Divider(
              color: AppColors.secondary,
              thickness: 2,
              endIndent: 170,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.0,
              children: [
                ActionButton(
                  icon: Icons.shopping_bag,
                  title: 'Market',
                  color: AppColors.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Market(),
                      ),
                    ).then(
                      (_) {
                        _getNotifications();
                      },
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.forum,
                  title: 'My Requests',
                  color: AppColors.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyRequests(),
                      ),
                    ).then(
                      (_) {
                        _getNotifications();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
