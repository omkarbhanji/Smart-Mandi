import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/theme.dart'; // 👈 import your theme

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  bool obsPassword = true;
  String error = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  final String _selectedRole = 'farmer'; // default

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void showPassword() {
    setState(() {
      obsPassword = !obsPassword;
    });
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    final signupData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text.trim(),
      "phone": _phoneController.text.trim(),
      "role": _selectedRole,
      "location": _locationController.text.trim(),
      "state": _stateController.text.trim(),
      "latitude": 18.5204,
      "longitude": 73.8567,
    };

    final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/users/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await saveToken(token);
        print("✅ Sign-up Successful: $data");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          error = data['message'] ?? "Signup failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Something went wrong. Please check your connection.";
      });
      print("❌ Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: const Icon(Icons.agriculture),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 👨‍🌾 Header
                  Text(
                    "Join Smart Mandi 👨‍🌾",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Create your account to get started",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🧍 Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      labelText: "Full Name",
                    ),
                    validator: (val) => val!.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 20),

                  // ✉️ Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: "Email",
                    ),
                    validator: (val) =>
                        val!.isEmpty ? "Enter your email" : null,
                  ),
                  const SizedBox(height: 20),

                  // 🔒 Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: obsPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(obsPassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: showPassword,
                      ),
                    ),
                    validator: (val) => val!.length < 8
                        ? "Minimum 8 characters required"
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // 📞 Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined),
                      labelText: "Phone Number",
                    ),
                    validator: (val) =>
                        val!.isEmpty ? "Enter your phone number" : null,
                  ),
                  const SizedBox(height: 20),

                  // 📍 Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_city_outlined),
                      labelText: "Location (City)",
                    ),
                    validator: (val) => val!.isEmpty ? "Enter your city" : null,
                  ),
                  const SizedBox(height: 20),

                  // 🗺️ State
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.map_outlined),
                      labelText: "State",
                    ),
                    validator: (val) =>
                        val!.isEmpty ? "Enter your state" : null,
                  ),
                  const SizedBox(height: 28),

                  // 🟢 Sign Up Button
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text("Sign Up"),
                  ),

                  const SizedBox(height: 16),

                  if (error.isNotEmpty)
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),

                  const SizedBox(height: 20),

                  // 🔁 Switch to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 15),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
