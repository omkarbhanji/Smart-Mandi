import 'package:flutter/material.dart';
import 'package:frontend_customer/services/capitalize_text.dart';
import 'package:frontend_customer/theme.dart';
import 'package:frontend_customer/widgets/detail_row_text.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;

  RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final farmer = request['farmer']; // may be null if not accepted
    final inventory = request['inventory'];

    Color statusColor;
    switch (request['status']) {
      case 'accepted':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Name
            Text(
              capitalize(inventory['cropName']),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Crop Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRowText(
                  icon: Icons.scale_outlined,
                  text:
                      '${inventory['quantity']} ${capitalize(inventory['unit'])}',
                  color: AppColors.primary,
                ),
                DetailRowText(
                  icon: Icons.currency_rupee,
                  text:
                      '₹${inventory['price']} per ${capitalize(inventory['unit'])}',
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status
            Text(
              "Status: ${capitalize(request['status'])}",
              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
            ),
            const SizedBox(height: 8),

            // Farmer Contact (only if accepted)
            if (request['status'] == 'accepted' && farmer != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    "Farmer Contact",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700]),
                  ),
                  const SizedBox(height: 4),
                  if (farmer['name'] != null)
                    DetailRowText(
                        icon: Icons.person,
                        text: capitalize(farmer['name']),
                        color: AppColors.primary),
                  if (farmer['phone'] != null)
                    DetailRowText(
                        icon: Icons.phone,
                        text: farmer['phone'],
                        color: AppColors.primary),
                  if (farmer['email'] != null)
                    DetailRowText(
                        icon: Icons.email,
                        text: farmer['email'],
                        color: AppColors.primary),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
