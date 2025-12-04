import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isScanned = false;

  Future<void> _processQR(String qrText) async {
    try {
      final data = jsonDecode(qrText);
      final session = data['session'];
      final timestamp = data['timestamp'];
      final users = data['users'];

      final currentUserId = "USER_ID_SAMPLE";

      final user = users.firstWhere(
        (u) => u['user_id'] == currentUserId,
        orElse: () => null,
      );

      if (user == null) {
        _showMessage("Anda tidak terdaftar pada QR ini!");
        return;
      }

      final sudahAbsen = await _firestore
          .collection("absensi")
          .where("user_id", isEqualTo: currentUserId)
          .where("session", isEqualTo: session)
          .where("date",
              isEqualTo: DateTime.now().toIso8601String().substring(0, 10))
          .get();

      if (sudahAbsen.docs.isNotEmpty) {
        _showMessage(
            "Anda sudah melakukan ${session == "check_in" ? "Check In" : "Check Out"} hari ini.");
        return;
      }

      await _firestore.collection("absensi").add({
        "user_id": currentUserId,
        "user_name": user["user_name"],
        "session": session,
        "timestamp": timestamp,
        "absen_time": DateTime.now().toIso8601String(),
        "date": DateTime.now().toIso8601String().substring(0, 10),
      });

      _showMessage(
          "${session == "check_in" ? "Check In" : "Check Out"} berhasil!");
    } catch (e) {
      _showMessage("QR tidak valid!");
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA VIEW
          MobileScanner(
            onDetect: (capture) {
              if (_isScanned) return;

              final rawValue = capture.barcodes.first.rawValue;
              if (rawValue != null) {
                setState(() => _isScanned = true);
                _processQR(rawValue);
              }
            },
          ),

          /// TOP TEXT
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Scan QR Code",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// QR FRAME OVERLAY
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),

          /// BOTTOM TEXT
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Pindai Kode QR untuk Absensi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          /// CANCEL BUTTON
          Positioned(
            bottom: 30,
            left: 30,
            right: 30,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Batal",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
