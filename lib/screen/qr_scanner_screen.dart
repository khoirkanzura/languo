import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../users/rekapan/kehadiran_page.dart';

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
      final session = data['session']; // "check_in" atau "check_out"
      final timestamp = data['timestamp']; // optional payload
      final users = data['users']; // list user objects

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showMessage("Anda belum login!");
        return;
      }
      final currentUserId = user.uid;

      // Ambil user_name dari koleksi users jika perlu
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      final currentUserName =
          userDoc.exists ? (userDoc.data()?['user_name'] ?? '') : '';

      // Per tanggal hari ini (yyyy-MM-dd)
      final now = DateTime.now();
      final dateKey =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Cek apakah user ada di payload QR (opsional, tergantung QR)
      bool userInPayload = false;
      if (users is List) {
        try {
          userInPayload = users.any((u) => u['user_id'] == currentUserId);
        } catch (_) {
          userInPayload = false;
        }
      }

      // Jika payload QR harus memuat user, periksa
      if (users != null &&
          users is List &&
          users.isNotEmpty &&
          !userInPayload) {
        _showMessage("Anda tidak terdaftar pada QR ini!");
        return;
      }

      final docId = "${currentUserId}_$dateKey";
      final docRef = _firestore.collection('absensi').doc(docId);

      final docSnap = await docRef.get();

      final timeNow =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      if (session == "check_in") {
        if (docSnap.exists && (docSnap.data()?['check_in'] ?? '') != '') {
          _showMessage("Anda sudah Check In hari ini!");
          return;
        }
        // buat dokumen baru atau update check_in
        await docRef.set({
          "user_id": currentUserId,
          "user_name": currentUserName,
          "date": dateKey,
          "check_in": timeNow,
          "check_out": "", // belum
          "status": "Proses",
          "created_at": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _showMessage("Check In berhasil!", goToKehadiran: true);
      } else if (session == "check_out") {
        if (!docSnap.exists || (docSnap.data()?['check_in'] ?? '') == '') {
          _showMessage("Belum melakukan Check In hari ini!");
          return;
        }
        if ((docSnap.data()?['check_out'] ?? '') != '') {
          _showMessage("Anda sudah Check Out hari ini!");
          return;
        }

        // Tentukan status berdasar check_in time
        final checkIn = docSnap.data()?['check_in'] ?? '';
        String newStatus = 'Tepat Waktu';
        if (checkIn != null && checkIn.toString().contains(':')) {
          final parts = checkIn.toString().split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          // batas 08:10 -> terlambat jika lewat
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
      } else {
        _showMessage("Session QR tidak dikenali!");
      }
    } catch (e) {
      // jika json decode gagal atau error lainnya
      _showMessage("QR tidak valid!");
    } finally {
      // reset scanner setelah delay kecil supaya user bisa scan lagi jika perlu
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
