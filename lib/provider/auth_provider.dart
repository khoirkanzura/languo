import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  bool islogin = true;

  final form = GlobalKey<FormState>();
  String enteredEmail = "";
  String enteredPassword = "";

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;

    form.currentState!.save();

    try {
      if (islogin) {
        // LOGIN
        await _auth.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );
      } else {
        // REGISTER
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        // SIMPAN DATA USER KE FIRESTORE
        await _firestore.collection('users').doc(userCred.user!.uid).set({
          'email': enteredEmail,
          'createdAt': DateTime.now(),
        });
      }

      // Tidak perlu navigate ke Login Screen, biarkan saja
      notifyListeners();
    } catch (e) {
      print("Error Auth: $e");
    }
  }
}
