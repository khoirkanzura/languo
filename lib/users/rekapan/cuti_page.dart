import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/cuti_service.dart';

class RekapanCutiPage extends StatefulWidget {
  const RekapanCutiPage({super.key});

  @override
  State<RekapanCutiPage> createState() => _RekapanCutiPageState();
}

class _RekapanCutiPageState extends State<RekapanCutiPage> {
  final _cutiService = CutiService();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF335C81),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Cuti",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LIST REKAPAN
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _cutiService.getRekapanCuti(currentUser!.uid),
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
                    child: Text(
                      "Belum ada rekapan",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final d = docs[index].data() as Map<String, dynamic>;

                    DateTime tglMulai =
                        (d['tanggalMulai'] as Timestamp).toDate();
                    DateTime tglSelesai =
                        (d['tanggalSelesai'] as Timestamp).toDate();

                    return _buildRekapanCard(
                      kelas: d['kelas'] ?? '-',
                      perihal: d['perihal'] ?? 'Cuti',
                      tanggalIzin: _formatTanggal(tglMulai),
                      tanggalSelesai: _formatTanggal(tglSelesai),
                      status: d['status'] ?? 'Proses',
                      statusColor:
                          d['status'] == 'Proses' ? Colors.orange : Colors.red,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekapanCard({
    required String kelas,
    required String perihal,
    required String tanggalIzin,
    required String tanggalSelesai,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                kelas,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  status,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Perihal : $perihal",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("Izin       : $tanggalIzin"),
          const SizedBox(height: 4),
          Text("Selesai : $tanggalSelesai"),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf,
                  color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(DateTime date) {
    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }
}
