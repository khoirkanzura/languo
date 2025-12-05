import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class KehadiranPage extends StatefulWidget {
  const KehadiranPage({super.key});

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  String _formatDisplayDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final dayShort = DateFormat.E('id').format(dt);
      final dayNum = DateFormat('dd').format(dt);
      final monthShort = DateFormat.MMM('id').format(dt);
      final year = DateFormat('yyyy').format(dt);
      return "$dayShort, $dayNum $monthShort $year";
    } catch (_) {
      return isoDate;
    }
  }

  Color _getJamColor(String jam) {
    if (jam.isEmpty) return Colors.grey;
    if (jam.contains("--")) return Colors.grey;
    try {
      final parts = jam.split(":");
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h < 8 || (h == 8 && m <= 10)) {
        return const Color(0xFF4CAF50);
      }
      return const Color(0xFFF44336);
    } catch (_) {
      return Colors.black;
    }
  }

  Color _getKeluarColor(String jam) {
    if (jam.isEmpty || jam.contains("--")) return Colors.grey;
    return const Color(0xFF4CAF50);
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Proses':
        return const Color(0xFFFF9800);
      case 'Tepat Waktu':
        return const Color(0xFF4CAF50);
      case 'Terlambat':
        return const Color(0xFFF44336);
      case 'Belum':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _computeStatusFromCheckIn(String checkIn, String checkOut) {
    if (checkIn.isEmpty) return 'Belum';
    if (checkOut.isEmpty) return 'Proses';
    try {
      final parts = checkIn.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h > 8 || (h == 8 && m > 10)) return 'Terlambat';
      return 'Tepat Waktu';
    } catch (_) {
      return 'Tepat Waktu';
    }
  }

  Future<void> _performCheckOut(
      String docId, Map<String, dynamic> docData) async {
    final now = DateTime.now();
    final timeNow =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final checkIn = (docData['check_in'] ?? '').toString();
    String newStatus = _computeStatusFromCheckIn(checkIn, timeNow);

    // 🔥 PATH FIRESTORE YANG BENAR
    await _firestore
        .collection('absensi')
        .doc(currentUserId)
        .collection('absensi')
        .doc(docId)
        .update({
      'check_out': timeNow,
      'status': newStatus,
      'updated_at': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Check out berhasil!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2)),
    );
  }

  void _showCheckOutDialog(String docId, Map<String, dynamic> docData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _CountdownDialog(
          onCheckOut: () async {
            Navigator.pop(context);
            await _performCheckOut(docId, docData);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(child: Text('User belum login')),
      );
    }

    final stream = _firestore
        .collection('absensi')
        .doc(currentUserId)
        .collection('absensi')
        .orderBy('date', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF5C6F7E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Rekapan Kehadiran",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text('Belum ada data kehadiran'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final data = d.data() as Map<String, dynamic>;

                      final checkIn = (data['check_in'] ?? '').toString();
                      final checkOut = (data['check_out'] ?? '').toString();
                      final date = (data['date'] ?? '').toString();
                      final kelas = (data['kelas'] ?? 'Kelas').toString();
                      final status = (data['status'] ??
                              _computeStatusFromCheckIn(checkIn, checkOut))
                          .toString();

                      final displayDate =
                          date.isNotEmpty ? _formatDisplayDate(date) : date;

                      return _buildCard(
                        docId: d.id,
                        kelas: kelas,
                        masuk: checkIn.isEmpty ? '-- : --' : checkIn,
                        keluar: checkOut.isEmpty ? '-- : --' : checkOut,
                        tanggal: displayDate,
                        status: status,
                        rawData: data,
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String docId,
    required String kelas,
    required String masuk,
    required String keluar,
    required String tanggal,
    required String status,
    required Map<String, dynamic> rawData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kelas,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                tanggal,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFF44336),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Masuk : ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          masuk,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _getJamColor(masuk),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          "Keluar : ",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          keluar,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _getKeluarColor(keluar),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: status == 'Proses'
                        ? () => _showCheckOutDialog(docId, rawData)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'Proses'
                          ? const Color(0xFFE57368)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Check Out',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  final VoidCallback onCheckOut;

  const _CountdownDialog({required this.onCheckOut});

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _remainingSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onCheckOut();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Waktu check out anda',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF9800),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('18.00 - 18.10',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(_formatTime(_remainingSeconds),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _timer?.cancel();
                  widget.onCheckOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE57368),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text('Check out',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
