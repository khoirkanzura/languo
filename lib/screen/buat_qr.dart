import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  // CEK WAKTU ABSENSI (07.00 - 17.00)
  bool _isWithinTimeRange() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day, 7, 0);
    final end = DateTime(now.year, now.month, now.day, 17, 0);

    return now.isAfter(start) && now.isBefore(end);
  }

  // ======================================================
  // CEK STATUS USER: BELUM CHECK IN, SUDAH, DLL
  Future<String> _getSession() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final snapshot = await _firestore
        .collection("absensi")
        .doc("QR_GLOBAL")
        .collection(today)
        .get();

    // Tidak pakai user dari sini
    // sesi berlaku untuk SEMUA user
    // yang menentukan sesi itu scanner

    return "global"; // QR hanya untuk semua user, sesi ditentukan user saat scan
  }

  // ======================================================
  // TOKEN UNIK ANTI-CHEAT
  String _generateToken(int length) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final rand = Random.secure();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)])
        .join();
  }

  // ======================================================
  // GENERATE QR DENGAN EXPIRED TIME (10 DETIK)
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

      final now = DateTime.now();
      final timestamp = now.toIso8601String();
      final expiresAt = now.add(const Duration(seconds: 10)).toIso8601String();

      final token = _generateToken(12); // token anti pemalsuan

      final newQR = jsonEncode({
        'timestamp': timestamp,
        'expires_at': expiresAt,
        'token': token,
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
    if (!_isWithinTimeRange()) {
      return _errorScreen("Di luar jam absensi (07.00 - 17.00)");
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
  // ERROR SCREEN
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
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
