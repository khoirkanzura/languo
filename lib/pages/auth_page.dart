import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLogin
          ? LoginScreen(
              onRegisterTap: () {
                setState(() => showLogin = false);
              },
            )
          : RegisterScreen(
              onSignInTap: () {
                setState(() => showLogin = true);
              },
            ),
    );
  }
}
