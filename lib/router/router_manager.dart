import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// karyawan page
import '../pages/home_page.dart';
import '../pages/auth_page.dart';

// Admin pages

// Murid pages
import '../murid/home_murid.dart';

// ERROR PAGE
class UnknownRolePage extends StatelessWidget {
  const UnknownRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Role tidak dikenali"),
      ),
    );
  }
}

class RouteManager {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 Router utama setelah login
  static Future<Widget> getHomeByRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      return const AuthPage();
    }

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(user.uid).get();

    if (!snap.exists || !snap.data().toString().contains('role')) {
      return const UnknownRolePage();
    }

    final role = snap['role'];

    switch (role) {
      case "admin":
        return const HomePage(); // admin dashboard
      //case "karyawan":
      //return const Home(); // halaman karyawan
      case "murid":
        return const HomeMurid(); // halaman murid
      default:
        return const UnknownRolePage();
    }
  }
}
