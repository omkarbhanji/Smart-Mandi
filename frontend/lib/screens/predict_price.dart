import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme.dart';
import 'package:frontend/widgets/predict_price_dialog.dart';
import 'package:http/http.dart' as http;

class PredictPrice extends StatefulWidget {
  const PredictPrice({super.key});

  @override
  State<PredictPrice> createState() => _PredictPriceState();
}

class _PredictPriceState extends State<PredictPrice> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _cropName;
  bool _isLoading = false;

  final List<String> _crops = ['rice', 'potato', 'onion', 'cucumber'];
  // ignore: unused_field
  final List<String> _statuses = ['available', 'sold', 'stock'];

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse("${dotenv.env['BACKEND_URL']}/ml/predict_price");
      final token = await getToken();

      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(
            {"vegetable": _cropName},
          ),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          showPredictPriceDialog(context, data);
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
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Price Predict')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Text(
                    'Predict Crop Price',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Crop Name Input
                  DropdownButtonFormField<String>(
                    value: _cropName,
                    decoration: const InputDecoration(labelText: 'Crop Name'),
                    items: _crops
                        .map((crop) => DropdownMenuItem(
                              value: crop,
                              child: Text(
                                  crop[0].toUpperCase() + crop.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _cropName = value),
                    validator: (value) =>
                        value == null ? 'Please select a crop name' : null,
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 28),

                  // Submit Button or Loader
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _onSubmit,
                          icon: const Icon(Icons.attach_money,
                              color: AppColors.textDark),
                          label: const Text(
                            'Predict price',
                            style: TextStyle(color: AppColors.textDark),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentYellow,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shadowColor:
                                AppColors.accentYellow.withOpacity(0.5),
                            elevation: 8,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
