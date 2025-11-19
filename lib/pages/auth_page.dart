import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../pages/home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User SUDAH login → HomePage
        if (snapshot.hasData) {
          debugPrint("User logged in: ${snapshot.data?.email}");
          return const HomePage();
        }

        // User BELUM login → LoginScreen atau RegisterScreen
        debugPrint(
            "User not logged in - showing ${showLogin ? 'Login' : 'Register'}");

        if (showLogin) {
          return LoginScreen(
            onRegisterTap: () {
              setState(() => showLogin = false);
            },
          );
        } else {
          return RegisterScreen(
            onSignInTap: () {
              setState(() => showLogin = true);
            },
          );
        }
      },
    );
  }
}
