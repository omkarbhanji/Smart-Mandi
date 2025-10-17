// 📄 lib/widgets/inventory_card.dart
import 'package:flutter/material.dart';
import 'package:frontend/theme.dart';

class InventoryCard extends StatelessWidget {
  const InventoryCard({
    super.key,
    required this.item,
    required this.onManage,
    required this.onDelete,
  });

  final Map<String, dynamic> item;
  final VoidCallback onManage;
  final VoidCallback onDelete;

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
              left: BorderSide(color: AppColors.secondary, width: 6)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['cropName'][0].toString().toUpperCase() +
                  item['cropName'].toString().substring(1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Divider(height: 15, thickness: 1),
            _buildDetailRow(
                Icons.scale_outlined,
                'Quantity: ${item['quantity']} ${item['unit']}',
                AppColors.primary),
            _buildDetailRow(
                Icons.currency_rupee,
                'Price: ₹${item['price']} per ${item['unit']}',
                AppColors.primary),
            _buildDetailRow(Icons.location_pin, 'Status: ${item['status']}',
                AppColors.primary),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Manage'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
