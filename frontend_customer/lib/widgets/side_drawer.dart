import 'package:flutter/material.dart';
import 'package:frontend_customer/theme.dart';

class SideDrawer extends StatelessWidget {
  final Function showLogoutDialog;
  final String customerName;
  final String customerEmail;

  const SideDrawer({
    super.key,
    required this.showLogoutDialog,
    this.customerName = "Customer Name",
    this.customerEmail = "customer@example.com",
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(customerName),
            accountEmail: Text(customerEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.accentYellow,
              child: Text(
                customerName[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            decoration: BoxDecoration(
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
