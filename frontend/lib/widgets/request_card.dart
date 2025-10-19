import 'package:flutter/material.dart';
import 'package:frontend/services/buy_requests_service.dart';
import 'package:frontend/services/capitalize_text.dart';
import 'package:frontend/services/format_date.dart';
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

    void showInfoDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Buy request',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalize(inventory['cropName']),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    "Customer Contact",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700]),
                  ),
                  const SizedBox(height: 4),
                  DetailRowText(
                      icon: Icons.person,
                      text: capitalize(customer['name']),
                      color: AppColors.primary),
                  DetailRowText(
                      icon: Icons.date_range,
                      text: formatDate(request['createdAt']),
                      color: AppColors.primary),
                  DetailRowText(
                      icon: Icons.phone,
                      text: customer['phone'],
                      color: AppColors.primary),
                  DetailRowText(
                      icon: Icons.email,
                      text: customer['email'],
                      color: AppColors.primary),
                  DetailRowText(
                      icon: Icons.location_on,
                      text: customer['customerProfile']['address'],
                      color: AppColors.primary),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (request['status'] == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await acceptOrReject.call(request['id'], 'rejected');
                        await BuyRequestService.markAsSeen(
                            buyRequestId: request['id'], context: context);
                      },
                      child: const Text("Reject"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await acceptOrReject.call(request['id'], 'accepted');
                        await BuyRequestService.markAsSeen(
                            buyRequestId: request['id'], context: context);
                      },
                      child: const Text("Accept"),
                    ),
                  ],
                )
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        showInfoDialog();
      },
      child: Card(
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              // customer Contact

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    "Customer Contact",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700]),
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
                      Expanded(
                        child: DetailRowText(
                            icon: Icons.date_range,
                            text: formatDate(request['createdAt']),
                            color: AppColors.primary),
                      )
                    ],
                  ),
                ],
              ),

              // Status
              Text(
                "Status: ${capitalize(request['status'])}",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: statusColor),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
