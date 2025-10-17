import 'package:flutter/material.dart';
import 'package:frontend/theme.dart';

class PredictPrice extends StatefulWidget {
  const PredictPrice({super.key});

  @override
  State<PredictPrice> createState() => _PredictPriceState();
}

class _PredictPriceState extends State<PredictPrice> {
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

      //backend api call here
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
