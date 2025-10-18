import 'package:flutter/material.dart';
import 'package:frontend/services/capitalize_text.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/widgets/detail_row_text.dart';

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final Function(int, String) acceptOrReject;

  const RequestCard(
      {super.key, required this.request, required this.acceptOrReject});

  @override
  Widget build(BuildContext context) {
    final customer = request['customer'];
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DetailRowText(
                    icon: Icons.scale_outlined,
                    text:
                        '${inventory['quantity']} ${capitalize(inventory['unit'])}',
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: DetailRowText(
                    icon: Icons.currency_rupee,
                    text:
                        '₹${inventory['price']} per ${capitalize(inventory['unit'])}',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // customer Contact

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  "customer Contact",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (customer['name'] != null)
                      Expanded(
                          child: DetailRowText(
                              icon: Icons.person,
                              text: capitalize(customer['name']),
                              color: AppColors.primary)),
                    if (customer['phone'] != null)
                      Expanded(
                          child: DetailRowText(
                              icon: Icons.phone,
                              text: customer['phone'],
                              color: AppColors.primary)),
                  ],
                ),
                if (customer['email'] != null)
                  DetailRowText(
                      icon: Icons.email,
                      text: customer['email'],
                      color: AppColors.primary),
              ],
            ),

            const SizedBox(height: 8),
            // Status
            Text(
              "Status: ${capitalize(request['status'])}",
              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
            ),
            const SizedBox(height: 8),

            if (request['status'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      acceptOrReject.call(request['id'], 'rejected');
                    },
                    child: const Text("Reject"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      acceptOrReject.call(request['id'], 'accepted');
                    },
                    child: const Text("Accepet"),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
