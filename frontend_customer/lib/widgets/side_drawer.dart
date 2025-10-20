import 'package:flutter/material.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:frontend_customer/theme.dart';

class SideDrawer extends StatelessWidget {
  final Function showLogoutDialog;

  const SideDrawer({
    super.key,
    required this.showLogoutDialog,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? user = UserData.currentUser;

    final String userName = user?['name'] ?? 'username';
    final String userEmail = user?['email'] ?? 'user@example.com';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.accentYellow,
              child: Text(
                userName[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // close drawer
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }
}
