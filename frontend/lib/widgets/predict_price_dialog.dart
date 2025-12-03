import 'package:flutter/material.dart';
import 'package:frontend/theme.dart';

void showPredictPriceDialog(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) {
      final predictedPrice = double.parse(
        data['predicted_modal_price'].toString(),
      ).toStringAsFixed(2);

      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Card(
          elevation: 6,
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Prediction Result",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                _buildDetailRow(
                  Icons.agriculture,
                  "Crop: ${data['vegetable'].toString()[0].toUpperCase() + data['vegetable'].toString().substring(1)}",
                ),
                _buildDetailRow(
                  Icons.currency_rupee,
                  "Predicted Price: ₹$predictedPrice",
                  isBold: true,
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  "Date: ${data['date_used']}",
                ),
                const SizedBox(height: 10),
                const Text(
                  "⚠ This price is an estimate based on historical data. "
                  "The actual market price may vary slightly.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.secondary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildDetailRow(
  IconData icon,
  String text, {
  bool isBold = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6.0),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
