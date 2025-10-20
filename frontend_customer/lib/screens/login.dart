import 'dart:convert';
import 'package:frontend_customer/screens/home.dart';
import 'package:frontend_customer/screens/signup.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend_customer/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_customer/theme.dart'; // 👈 import your theme

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = '';
  String password = '';
  String error = '';
  final String role = "customer";
  bool obsPassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse("${dotenv.env['BACKEND_URL']}/api/users/login");

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim(),
          "password": password.trim(),
          "role": role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        await saveToken(token);
        UserData.currentUser = data['data']['user'];
        print("✅ Customer Login Successful: $data");

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          error = data['message'] ?? "Login failed. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        error = "Something went wrong. Please check your connection.";
      });
      print("❌ Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showPassword() {
    setState(() {
      obsPassword = !obsPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Customer Login'),
        leading: const Icon(Icons.shopping_bag_outlined), // 👈 Changed icon
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 450),
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
                  Text(
                    "Welcome Back, Customer 🛍️",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Login to explore products and place your orders",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ✉️ Email Field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined),
                      labelText: "Email",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter your email" : null,
                    onChanged: (value) => setState(() => email = value),
                  ),
                  const SizedBox(height: 20),

                  // 🔒 Password Field
                  TextFormField(
                    obscureText: obsPassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: "Password",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obsPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: showPassword,
                      ),
                    ),
                    validator: (value) =>
                        value!.length < 8 ? "Enter 8 char long password" : null,
                    onChanged: (value) => setState(() => password = value),
                  ),
                  const SizedBox(height: 28),

                  // 🟢 Login Button
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : loginUser, // disable when loading
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              backgroundColor: AppColors.primary,
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 16),

                  if (error.isNotEmpty)
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 15),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signup(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
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
