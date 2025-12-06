import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:languo/admin/verifikasi/sakit_verifikasi_admin_page.dart';
import '../../../services/sakit_service.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class RekapanAdminSakitPage extends StatefulWidget {
  final String role;

  const RekapanAdminSakitPage({super.key, required this.role});

  @override
  State<RekapanAdminSakitPage> createState() => _RekapanAdminSakitPageState();
}

class _RekapanAdminSakitPageState extends State<RekapanAdminSakitPage> {
  final _sakitService = SakitService();
  int selectedTab = 1; // langsung ke REKAPAN
  TextEditingController searchController = TextEditingController();
  int expandedIndex = -1;
  String keyword = "";

  // POPUP HAPUS
  void showDeleteConfirm(BuildContext context, String sakitId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Hapus data ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Batal",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          try {
                            await _sakitService.hapusPengajuanSakit(sakitId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Data berhasil dihapus")),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal menghapus: $e")),
                              );
                            }
                          }
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Hapus",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> openPdf(String url, BuildContext context) async {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka lampiran')),
          );
        }
      }
    }
  }

  String _formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          header(),
          _buildTabBar(),
          searchBar(),
          Expanded(child: RekapanList()),
        ],
      ),
    );
  }

  // HEADER
  Widget header() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF36546C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 10),
              Text(
                "Sakit  <  ${widget.role}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB
  Widget _buildTabBar() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(40),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  left: selectedTab == 0 ? 0 : tabWidth,
                  child: Container(
                    height: 55,
                    width: tabWidth,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepOrange, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _tab("Pengajuan", 0),
                    _tab("Rekapan", 1),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

// TAB BUTTON FIXED (Navigasi ke admin/verifikasi/sakit_page)
  Widget _tab(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 0) {
            // PENGAJUAN → menuju halaman verifikasi
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerifikasiSakitPage(role: widget.role),
              ),
            );
          } else {
            // REKAPAN (tetap di halaman ini)
            setState(() => selectedTab = index);
          }
        },
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedTab == index ? Colors.white : Colors.grey.shade700,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // SEARCH BAR
  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF9FB0BD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => keyword = v.toLowerCase()),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Cari Pengguna....",
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const Icon(Icons.search, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // LIST REKAPAN
  Widget RekapanList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _sakitService.getAllRekapanSakitAdmin(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        // Filter hanya status "Disetujui" dan "Ditolak"
        final rekapanDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? '';
          return status == 'Disetujui' || status == 'Ditolak';
        }).toList();

        if (rekapanDocs.isEmpty) {
          return const Center(
            child: Text(
              "Tidak ada rekapan sakit",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        // Filter berdasarkan keyword
        var filtered = rekapanDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nama = (data['userName'] ?? '').toString().toLowerCase();
          return nama.contains(keyword);
        }).toList();

        if (filtered.isEmpty && keyword.isNotEmpty) {
          return const Center(
            child: Text(
              "Pengguna tidak ditemukan",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;
            return SakitCard(doc.id, data, index);
          },
        );
      },
    );
  }

  // CARD UTAMA
  Widget SakitCard(String sakitId, Map<String, dynamic> data, int index) {
    bool isExpanded = expandedIndex == index;

    final nama = data['userName'] ?? '-';
    final email = data['userEmail'] ?? '-';
    final status = data['status'] ?? 'Diajukan';
    final lampiranUrl = data['lampiranUrl'] as String?;
    final fileName = data['fileName'] ?? 'surat_sakit.pdf';

    final tanggalMulai = (data['tanggalMulai'] as Timestamp?)?.toDate();
    final tanggalSelesai = (data['tanggalSelesai'] as Timestamp?)?.toDate();
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

    String periode = "-";
    if (tanggalMulai != null && tanggalSelesai != null) {
      periode =
          "${_formatTanggal(tanggalMulai)} s.d ${_formatTanggal(tanggalSelesai)}";
    }

    String tanggalPengajuan = "-";
    if (createdAt != null) {
      tanggalPengajuan = _formatTanggal(createdAt);
    }

    Color badgeColor =
        status == "Disetujui" ? Colors.green : Colors.red;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(207, 237, 236, 236),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today, color: Colors.red),
              const SizedBox(width: 10),

              // INFORMASI UTAMA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text("Periode Sakit :",
                        style: TextStyle(color: Colors.black54)),
                    Text(periode,
                        style: const TextStyle(
                            color: Color(0xFFDA3B26),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // KOLOM KANAN (STATUS + PANAH)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // STATUS
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // PANAH
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDA3B26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // DETAIL CARD
          if (isExpanded) ...[
            const SizedBox(height: 15),

            detailRow("Alamat Email :", email),
            detailRow("Tanggal Pengajuan :", tanggalPengajuan),
            detailRow("Status :", status),

            const SizedBox(height: 15),

            // FILE BUTTON
            if (lampiranUrl != null && lampiranUrl.isNotEmpty)
              GestureDetector(
                onTap: () => openPdf(lampiranUrl, context),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.white),
                      const SizedBox(width: 8),
                      Text("File ($fileName)",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 15),

            // HAPUS POSISI KANAN
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => showDeleteConfirm(context, sakitId),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }
}