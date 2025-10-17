import 'package:flutter/material.dart';
import 'package:frontend/screens/add_crop.dart';
import 'package:frontend/screens/inventory.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/screens/predict_price.dart';

import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/widgets/action_button.dart';
import 'package:frontend/widgets/side_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentPage = 0;

  final List<String> sliderImages = [
    'https://placehold.co/600x250/059669/FFFFFF?text=Field+Harvest',
    'https://placehold.co/600x250/10B981/FFFFFF?text=Market+Trends',
    'https://placehold.co/600x250/047857/FFFFFF?text=Quality+Produce',
  ];

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
  Widget build(BuildContext context) {
    const farmerName = 'Farmer';

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You have 0 new inquiries!')),
                  );
                },
              ),
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
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: SideDrawer(
        farmerName: "Farmer", // or fetch dynamically
        farmerEmail: "farmer@example.com",
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
              farmerName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildImageSlider(),
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
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                ActionButton(
                  icon: Icons.add_circle,
                  title: 'Add New Crop',
                  color: AppColors.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCrop(),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.inventory,
                  title: 'Inventory',
                  color: AppColors.primary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Inventory(),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.bar_chart,
                  title: 'Predict Crop Price',
                  color: Colors.amber,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PredictPrice(),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.settings_suggest,
                  title: 'New Feature',
                  color: Colors.blueGrey,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('This feature is coming soon!')),
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

  Widget _buildImageSlider() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: sliderImages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    sliderImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.secondary.withOpacity(0.2),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: sliderImages.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == entry.key
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
