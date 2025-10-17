import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/login.dart';
import 'package:frontend/services/auth_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == false) {
          return const Login();
        } else {
          return const Home();
        }
      },
    );
  }
}

// class _WrapperState extends State<Wrapper> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<bool>(
//       future: checkLoginStatus(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show custom splash instead of simple loader
//           return const CustomSplashScreen();
//         } else if (snapshot.hasError || snapshot.data == false) {
//           return const AuthPage();
//         } else {
//           return const Home();
//         }
//       },
//     );
//   }
// }
