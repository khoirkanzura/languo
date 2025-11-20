import 'package:flutter/material.dart';

class KehadiranPage extends StatelessWidget {
  const KehadiranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF36546C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Rekapan Kehadiran",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= LIST DATA =================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCard(
                    kelas: "Kelas Mandarin",
                    masuk: "08:06",
                    keluar: "-- : --",
                    tanggal: "Jum, 30 Okt 2025",
                    status: "Proses",
                    statusColor: Colors.orange,
                  ),
                  _buildCard(
                    kelas: "Kelas Jepang",
                    masuk: "08:00",
                    keluar: "18:07",
                    tanggal: "Jum, 30 Okt 2025",
                    status: "Tepat Waktu",
                    statusColor: Colors.green,
                  ),
                  _buildCard(
                    kelas: "Kelas Jerman",
                    masuk: "08:15",
                    keluar: "18:00",
                    tanggal: "Jum, 30 Okt 2025",
                    status: "Terlambat",
                    statusColor: Colors.red,
                  ),
                  _buildCard(
                    kelas: "Kelas Jerman",
                    masuk: "-- : --",
                    keluar: "-- : --",
                    tanggal: "Jum, 30 Okt 2025",
                    status: "Belum",
                    statusColor: Colors.grey,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================================
  //               WARNA OTOMATIS JAM MASUK/KELUAR
  // ==========================================================
  Color _getJamColor(String jam) {
    if (jam.contains("--")) return Colors.grey;

    try {
      final parts = jam.split(":");
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);

      if (h < 8 || (h == 8 && m <= 10)) {
        return Colors.green;
      }

      return Colors.red;
    } catch (_) {
      return Colors.black;
    }
  }

  // ==========================================================
  //                       CARD WIDGET
  // ==========================================================
  Widget _buildCard({
    required String kelas,
    required String masuk,
    required String keluar,
    required String tanggal,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
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
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                tanggal,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 10, 0, 0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 2: Icon, Masuk/Keluar, dan Status
          Row(
            children: [
              // Icon
              const Icon(Icons.location_on, color: Colors.red, size: 28),
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
                          ),
                        ),
                        Text(
                          keluar,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _getJamColor(keluar),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
