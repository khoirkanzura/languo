import 'dart:async';
import 'dart:convert';
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

  String qrData = "";
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _refreshQR();

    timer = Timer.periodic(
      const Duration(seconds: 10),
      (t) => _refreshQR(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ======================================================
  // BATAS WAKTU ABSENSI (07.00 - 17.00)
  bool _isWithinTimeRange() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day, 7, 0); // 07.00
    final end = DateTime(now.year, now.month, now.day, 17, 0); // 17.00

    return now.isAfter(start) && now.isBefore(end);
  }

  // DETEKSI SESI CHECK-IN / CHECK-OUT
  String _detectSession() {
    final now = DateTime.now();

    final checkInEnd = DateTime(now.year, now.month, now.day, 8, 0);
    final checkOutStart = DateTime(now.year, now.month, now.day, 9, 0);
    final checkOutEnd = DateTime(now.year, now.month, now.day, 17, 0);

    if (now.isBefore(checkInEnd)) {
      return "check_in";
    } else if (now.isAfter(checkOutStart) && now.isBefore(checkOutEnd)) {
      return "check_out";
    } else {
      return "invalid_checkout";
    }
  }

  // ======================================================
  // GENERATE QR DENGAN JSON
  Future<void> _refreshQR() async {
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

      final newQR = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'session': session,
        'users': users,
      });

      setState(() {
        qrData = newQR;
      });
    } catch (e) {
      print("ERROR GENERATE QR: $e");
    }
  }

  // ======================================================
  // HEADER UI
  Widget _buildHeader() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF36546C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text(
              "QR Absensi",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  @override
  Widget build(BuildContext context) {
    final session = _detectSession();

    if (!_isWithinTimeRange()) {
      return _errorScreen("Di luar jam absensi (07.00 - 17.00)");
    }

    if (session == "invalid_checkout") {
      return _errorScreen(
        "Tidak bisa absen sekarang.\n"
        "Check-in: 07.00 - 08.00\n"
        "Check-out: 09.00 - 17.00",
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double qrSize = constraints.maxWidth * 0.55;
                qrSize = qrSize.clamp(180, 300);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF345A75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            session == "check_in"
                                ? "SESI CHECK-IN"
                                : "SESI CHECK-OUT",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tanggal : ${DateFormat('dd-MM-yyyy').format(DateTime.now())}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 25),
                        Center(
                          child: qrData.isEmpty
                              ? const CircularProgressIndicator()
                              : QrImageView(
                                  data: qrData,
                                  size: qrSize,
                                ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Waktu : ${DateFormat('HH:mm:ss').format(DateTime.now())}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // ERROR SCREEN SESUAI GAMBAR
  Widget _errorScreen(String text) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          "!",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "SESI ABSENSI SUDAH\nMELEWATI WAKTU\n07.00 – 17.00 WIB",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
