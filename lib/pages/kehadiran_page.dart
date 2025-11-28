import 'package:flutter/material.dart';
import 'dart:async';

class KehadiranPage extends StatefulWidget {
  const KehadiranPage({super.key});

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  // State untuk menyimpan data kehadiran
  List<Map<String, dynamic>> kehadiranList = [
    {
      'kelas': 'Kelas Mandarin',
      'masuk': '08:11',
      'keluar': '-- : --',
      'tanggal': 'Jum, 30 Okt 2025',
      'status': 'Proses',
    },
    {
      'kelas': 'Kelas Mandarin',
      'masuk': '08:00',
      'keluar': '18:00',
      'tanggal': 'Jum, 30 Okt 2025',
      'status': 'Tepat Waktu',
    },
    {
      'kelas': 'Kelas Mandarin',
      'masuk': '08:15',
      'keluar': '18:05',
      'tanggal': 'Jum, 30 Okt 2025',
      'status': 'Terlambat',
    },
    {
      'kelas': 'Kelas Mandarin',
      'masuk': '-- : --',
      'keluar': '-- : --',
      'tanggal': 'Jum, 30 Okt 2025',
      'status': 'Belum',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            // List Data
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kehadiranList.length,
                itemBuilder: (context, index) {
                  return _buildCard(
                    context: context,
                    index: index,
                    data: kehadiranList[index],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Menampilkan dialog saat button Check Out diklik
  void _showCheckOutDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _CountdownDialog(
          onCheckOut: () {
            Navigator.pop(context);
            _handleCheckOut(index);
          },
        );
      },
    );
  }

  // Mengupdate data setelah checkout berhasil
  void _handleCheckOut(int index) {
    // Hitung status berdasarkan waktu masuk
    String masuk = kehadiranList[index]['masuk'];
    String newStatus = 'Tepat Waktu';
    
    if (!masuk.contains('--')) {
      try {
        final parts = masuk.split(":");
        final h = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        
        // Jika masuk setelah 08:10, maka terlambat
        if (h > 8 || (h == 8 && m > 10)) {
          newStatus = 'Terlambat';
        }
      } catch (_) {
        newStatus = 'Tepat Waktu';
      }
    }

    setState(() {
      // Update waktu keluar dengan waktu saat ini (simulasi)
      kehadiranList[index]['keluar'] = '18:08';
      kehadiranList[index]['status'] = newStatus;
    });

    // Tampilkan snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Check out berhasil!'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getJamColor(String jam) {
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

  // Warna khusus untuk waktu keluar (selalu hijau jika sudah terisi)
  Color _getKeluarColor(String jam) {
    if (jam.contains("--")) return Colors.grey;
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

  Widget _buildCard({
    required BuildContext context,
    required int index,
    required Map<String, dynamic> data,
  }) {
    String kelas = data['kelas'];
    String masuk = data['masuk'];
    String keluar = data['keluar'];
    String tanggal = data['tanggal'];
    String status = data['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Row 1: Kelas dan Tanggal
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

          // Row 2: Icon + Jam, Status, Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Location
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

              // Jam Masuk & Keluar
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

              // Status dan Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

                  // Check Out Button
                  ElevatedButton(
                    onPressed: status == 'Proses'
                        ? () => _showCheckOutDialog(index)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: status == 'Proses'
                          ? const Color(0xFFE57368)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
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

// Widget Dialog dengan Countdown Timer 
class _CountdownDialog extends StatefulWidget {
  final VoidCallback onCheckOut;

  const _CountdownDialog({required this.onCheckOut});

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _remainingSeconds = 60; // 1 menit = 60 detik
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  // Countdown timer berjalan otomatis
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        // Auto checkout ketika countdown selesai
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Waktu check out anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Time Range Badge (Orange)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '18.00 - 18.10',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Countdown Timer Badge (Green) 
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Check Out Button
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
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Check out',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}