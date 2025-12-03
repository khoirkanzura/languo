import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class BuatQRPage extends StatefulWidget {
  const BuatQRPage({super.key});

  @override
  State<BuatQRPage> createState() => _BuatQRPageState();
}

class _BuatQRPageState extends State<BuatQRPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cek rentang absen
  bool _isWithinTimeRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 7, 0);
    final end = DateTime(now.year, now.month, now.day, 17, 0);
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Tentukan sesi check in / check out
  String _detectSession() {
    final now = DateTime.now();
    final checkInLimit = DateTime(now.year, now.month, now.day, 8, 0);

    if (now.isBefore(checkInLimit)) {
      return "check_in";
    } else if (now.isAfter(DateTime(now.year, now.month, now.day, 17, 0))) {
      return "invalid_checkout";
    } else {
      return "check_out";
    }
  }

  /// Ambil data real-time dari Firestore sesuai AuthProvider
  Future<String> _generateQRData() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'user_id': data['user_id'],
          'user_name': data['user_name'],
          'user_email': data['user_email'],
          'user_role': data['user_role'],
        };
      }).toList();

      final session = _detectSession();

      return {
        'timestamp': DateTime.now().toIso8601String(),
        'session': session,
        'users': users,
      }.toString();
    } catch (e) {
      print("ERROR GENERATE QR: $e");
      return "error";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Absensi Realtime Firebase"),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _generateQRData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData || snapshot.data == "error") {
              return const Text(
                "Gagal memuat data QR",
                style: TextStyle(color: Colors.red, fontSize: 18),
              );
            }

            final qrData = snapshot.data!;
            final session = _detectSession();

            if (!_isWithinTimeRange()) {
              return const Text(
                "Di luar jam absensi (07:00 - 17:00)",
                style: TextStyle(color: Colors.red, fontSize: 18),
              );
            }

            if (session == "invalid_checkout") {
              return const Text(
                "Tidak bisa checkout setelah jam 17.00",
                style: TextStyle(color: Colors.red, fontSize: 18),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QrImageView(
                  data: qrData,
                  size: 280,
                ),
                const SizedBox(height: 20),
                Text(
                  session == "check_in" ? "Sesi: Check In" : "Sesi: Check Out",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Waktu: ${DateFormat('HH:mm').format(DateTime.now())}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
