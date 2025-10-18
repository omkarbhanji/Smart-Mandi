import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme.dart';
import 'package:http/http.dart' as http;

class AddCrop extends StatefulWidget {
  const AddCrop({super.key});

  @override
  State<AddCrop> createState() => _AddCropState();
}

class _AddCropState extends State<AddCrop> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _cropName;
  int? _quantity;
  String? _unit;
  double? _pricePerUnit;
  String? _status;
  bool _isLoading = false;

  final List<String> _units = ['kg', 'quintal', 'ton'];
  final List<String> _statuses = ['available', 'sold', 'stock'];

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final cropData = {
        'cropName': _cropName,
        'quantity': _quantity,
        'unit': _unit,
        'price': _pricePerUnit,
        'status': _status,
      };

      setState(() => _isLoading = true);

      final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/inventory");
      final token = await getToken();

      try {
        final response = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
          body: jsonEncode(cropData),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Crop added successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context);
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop')),
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
                    'Add Your Crop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Crop Name Input
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Crop Name',
                      hintText: 'e.g., Wheat, Onion',
                    ),
                    onChanged: (value) => _cropName = value,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter crop name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Quantity Input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            hintText: 'e.g., 50',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) =>
                              _quantity = int.tryParse(value.trim()),
                          validator: (value) => (value == null ||
                                  int.tryParse(value) == null ||
                                  int.parse(value) <= 0)
                              ? 'Enter a valid quantity'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unit,
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: _units
                              .map((unit) => DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit[0].toUpperCase() +
                                        unit.substring(1)),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _unit = value),
                          validator: (value) =>
                              value == null ? 'Please select a unit' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price Input
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price per Unit (₹)',
                      hintText: 'e.g., 1200',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) =>
                        _pricePerUnit = double.tryParse(value.trim()),
                    validator: (value) => (value == null ||
                            double.tryParse(value) == null ||
                            double.parse(value) <= 0)
                        ? 'Enter a valid price'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status[0].toUpperCase() +
                                  status.substring(1)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value),
                    validator: (value) =>
                        value == null ? 'Please select a status' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button or Loader
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _onSubmit,
                          icon:
                              const Icon(Icons.add, color: AppColors.textDark),
                          label: const Text(
                            'Add Crop',
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
