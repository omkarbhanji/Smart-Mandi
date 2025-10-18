import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:frontend_customer/theme.dart';
import 'package:frontend_customer/widgets/detail_row_text.dart';
import 'package:http/http.dart' as http;
import 'package:frontend_customer/services/capitalize_text.dart';

class InventoryCard extends StatefulWidget {
  const InventoryCard({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  void _sendBuyRequest(int inventoryId) async {
    final token = await getToken();

    final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/buyRequest/");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"inventoryId": inventoryId}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. $e'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: const Border(
            left: BorderSide(color: AppColors.secondary, width: 6),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟩 Crop Name
            Text(
              capitalize(widget.item['cropName']),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: 15, thickness: 1),

            // 🟩 Info rows (two-column layout)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Quantity, Price
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.item['farmer']?['name'] != null)
                        DetailRowText(
                          icon: Icons.person_outline,
                          text: capitalize(widget.item['farmer']['name']),
                          color: AppColors.primary,
                        ),
                      DetailRowText(
                        icon: Icons.scale_outlined,
                        text:
                            'Quantity: ${widget.item['quantity']} ${widget.item['unit']}',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                // Right column: Location, Farmer, Status
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.item['farmer']?['farmerProfile'] != null)
                        DetailRowText(
                          icon: Icons.location_on_outlined,
                          text:
                              '${capitalize(widget.item['farmer']['farmerProfile']['location'])}, ${capitalize(widget.item['farmer']['farmerProfile']['state'])}',
                          color: AppColors.primary,
                        ),
                      DetailRowText(
                        icon: Icons.currency_rupee,
                        text:
                            '₹${widget.item['price']} per ${widget.item['unit']}',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _sendBuyRequest(widget.item['inventoryId']);
                    },
                    child: const Text("I'm interested")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
