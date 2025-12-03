import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'verifikasi/cuti_page.dart';
import 'verifikasi/izin_page.dart';
import 'verifikasi/sakit_page.dart';

class NotifikasiAdminPage extends StatefulWidget {
  const NotifikasiAdminPage({super.key});

  @override
  State<NotifikasiAdminPage> createState() => _NotifikasiAdminPageState();
}

class _NotifikasiAdminPageState extends State<NotifikasiAdminPage> {
  TextEditingController searchController = TextEditingController();

  // LIST NOTIFIKASI KHUSUS ADMIN
  List<Map<String, String>> notifAdmin = [
    {
      "jenis": "Pengajuan Cuti",
      "nama": "KARTIKA TRI JULIANA",
      "tanggal": "30 Nov 2025 s.d 1 Des 2025"
    },
    {
      "jenis": "Pengajuan Izin",
      "nama": "ISMI ATIKA",
      "tanggal": "30 Nov 2025 s.d 1 Des 2025"
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

    // FILTER BERDASARKAN NAMA / JENIS CUTI
    List filtered = notifAdmin.where((item) {
      return item["jenis"]!.toLowerCase().contains(query) ||
          item["nama"]!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====================== HEADER ======================
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

                // Title + Back
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 16, right: 16),
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

            // ====================== SEARCH BAR ======================
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

            // ====================== LIST NOTIFIKASI ======================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AdminNotifCard(
                      jenis: filtered[index]["jenis"]!,
                      nama: filtered[index]["nama"]!,
                      tanggal: filtered[index]["tanggal"]!,
                      onTap: () {
                        if (filtered[index]["jenis"] == "Pengajuan Cuti") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CutiPage(
                                      role: 'Karyawan',
                                    )),
                          );
                        } else if (filtered[index]["jenis"] ==
                            "Pengajuan Izin") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const IzinPage(
                                      role: 'Karyawan',
                                    )),
                          );
                        } else if (filtered[index]["jenis"] ==
                            "Pengajuan Sakit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SakitPage(
                                      role: 'Karyawan',
                                    )),
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
//                    WIDGET KARTU NOTIFIKASI ADMIN
// ===============================================================

class AdminNotifCard extends StatelessWidget {
  final String jenis;
  final String nama;
  final String tanggal;

  final VoidCallback onTap;

  const AdminNotifCard({
    super.key,
    required this.jenis,
    required this.nama,
    required this.tanggal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9), // kotak luar
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== BAGIAN KIRI =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 10),
                    const SizedBox(width: 6),
                    Text(
                      jenis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Kotak dalam yg ada ikon + nama
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month,
                          size: 20, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Periode Tanggal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Periode ${jenis.contains('Izin') ? 'Izin' : 'Cuti'}  :",
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      tanggal,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ===== TOMBOL PANAH =====
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFE7633B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
