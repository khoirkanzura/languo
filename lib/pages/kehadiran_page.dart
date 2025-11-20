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
            // ===================== HEADER =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF36546C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Rekapan Kehadiran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ===================== LIST DATA =====================
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

  // ===================== CARD WIDGET =====================
  Widget _buildCard({
    required String kelas,
    required String masuk,
    required String keluar,
    required String tanggal,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F7),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================== ICON =====================
          const Icon(Icons.location_on, color: Colors.red, size: 28),

          const SizedBox(width: 15),

          // ===================== TEXT DATA =====================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tanggal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Masuk :  $masuk",
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87)),
                Text("Keluar :  $keluar",
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),

          // ===================== STATUS =====================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
