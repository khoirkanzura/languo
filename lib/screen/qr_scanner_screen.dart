import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../users/rekapan/kehadiran_rekapan_user_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isScanned = false;

  // ==============================
  // CEK JAM 07:00 - 17:00
  bool _isWithinTimeRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 7, 0);
    final end = DateTime(now.year, now.month, now.day, 17, 0);
    return now.isAfter(start) && now.isBefore(end);
  }
  // ==============================

  Future<void> _processQR(String qrText) async {
    try {
      if (!_isWithinTimeRange()) {
        _showMessage("Di luar jam absensi (07.00 - 17.00)");
        return;
      }

      final data = jsonDecode(qrText);
      final expiresAtStr = data['expires_at'];
      final token = data['token']; // anti fake
      if (expiresAtStr == null || token == null) {
        _showMessage("QR tidak valid!");
        return;
      }

      // Cek expired
      final expiresAt = DateTime.tryParse(expiresAtStr);
      if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
        _showMessage("QR sudah kedaluwarsa!");
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("Anda belum login!");
        return;
      }

      final currentUserId = user.uid;

      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final currentUserName =
          userDoc.exists ? (userDoc.data()?['user_name'] ?? '') : '';

      final now = DateTime.now();
      final dateKey =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final docId = "${currentUserId}_$dateKey";
      final docRef = _firestore.collection('absensi').doc(docId);

      final docSnap = await docRef.get();

      final timeNow =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // =========================================
      // LOGIKA BARU: OTOMATIS TENTUKAN SESI
      // =========================================
      bool hasCheckIn =
          docSnap.exists && (docSnap.data()?['check_in'] ?? '') != '';
      bool hasCheckOut =
          docSnap.exists && (docSnap.data()?['check_out'] ?? '') != '';

      // ===== CHECK-IN =====
      if (!hasCheckIn) {
        await docRef.set({
          "user_id": currentUserId,
          "user_name": currentUserName,
          "date": dateKey,
          "check_in": timeNow,
          "check_out": "",
          "status": "Proses",
          "created_at": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _showMessage("Check In berhasil!", goToKehadiran: true);
        return;
      }

      // ===== CHECK-OUT =====
      if (hasCheckIn && !hasCheckOut) {
        // Tentukan status
        final checkIn = docSnap.data()?['check_in'] ?? '';
        String newStatus = 'Tepat Waktu';

        if (checkIn.contains(':')) {
          final parts = checkIn.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;

          if (h > 8 || (h == 8 && m > 10)) {
            newStatus = 'Terlambat';
          }
        }

        await docRef.update({
          "check_out": timeNow,
          "status": newStatus,
          "updated_at": FieldValue.serverTimestamp(),
        });

        _showMessage("Check Out berhasil!", goToKehadiran: true);
        return;
      }

      // ===== SUDAH COMPLETELY ABSEN =====
      if (hasCheckIn && hasCheckOut) {
        _showMessage("Anda sudah Check-In dan Check-Out hari ini!");
        return;
      }
    } catch (e) {
      _showMessage("QR tidak valid!");
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() => _isScanned = false);
      });
    }
  }

  void _showMessage(String text, {bool goToKehadiran = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (goToKehadiran) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KehadiranPage()),
        );
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
