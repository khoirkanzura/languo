import 'package:flutter/material.dart';
import 'package:languo/users/rekapan/cuti_rekapan_page.dart';
import 'package:languo/users/rekapan/izin_rekapan_page.dart';
import 'package:languo/users/rekapan/sakit_rekapan_page.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  TextEditingController searchController = TextEditingController();

  // ========= LIST NOTIFIKASI =========
  List<Map<String, dynamic>> notifList = [
    {
      "jenis": "Pengajuan Anda Ditolak Cuti",
      "nama": "KARTIKA TRI JULIANA",
      "tanggal": "30 Nov 2025 s.d 1 Des 2025",
      "status": "Ditolak",
      "statusColor": Colors.red,
      "dotColor": Colors.grey,
    },
    {
      "jenis": "Pengajuan Anda Diterima Cuti",
      "nama": "KARTIKA TRI JULIANA",
      "tanggal": "30 Nov 2025 s.d 1 Des 2025",
      "status": "Diterima",
      "statusColor": Colors.green,
      "dotColor": Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    String query = searchController.text.toLowerCase();

    List filteredList = notifList.where((n) {
      return n["nama"].toLowerCase().contains(query) ||
          n["jenis"].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================== HEADER =======================
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFF36546C),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -18,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 140,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 70),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                      const Text(
                        "Notifikasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===================== SEARCH BAR =======================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EEF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Cari...",
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===================== LIST NOTIFIKASI =======================
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text(
                        "Data tidak ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (_, index) {
                        final n = filteredList[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: NotifikasiCard(
                            jenis: n["jenis"],
                            nama: n["nama"],
                            tanggal: n["tanggal"],
                            status: n["status"],
                            statusColor: n["statusColor"],
                            dotColor: n["dotColor"],
                            onTap: () {
                              // ===============================
                              //     NAVIGASI KE REKAPAN
                              // ===============================
                              if (n["jenis"].toLowerCase().contains("cuti")) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RekapanCutiPage()),
                                );
                              } else if (n["jenis"]
                                  .toLowerCase()
                                  .contains("izin")) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RekapanIzinPage()),
                                );
                              } else if (n["jenis"]
                                  .toLowerCase()
                                  .contains("sakit")) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RekapanSakitPage()),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
//                     WIDGET KARTU NOTIFIKASI
// ===============================================================

class NotifikasiCard extends StatelessWidget {
  final String jenis;
  final String nama;
  final String tanggal;
  final String? status;
  final Color? statusColor;
  final Color dotColor;
  final VoidCallback onTap;

  const NotifikasiCard({
    super.key,
    required this.jenis,
    required this.nama,
    required this.tanggal,
    required this.status,
    required this.statusColor,
    required this.dotColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // <-- INI YANG BUAT MASUK REKAPAN
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Judul + Status badge =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: dotColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      jenis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (status != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ===== Nama =====
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ===== Periode + Arrow =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Periode Cuti  :",
                        style: TextStyle(fontSize: 12)),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE65A3A),
                  child: Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
