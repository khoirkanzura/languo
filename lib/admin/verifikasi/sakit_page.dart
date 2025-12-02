import 'package:flutter/material.dart';
import 'package:languo/admin/rekapan/sakit_page.dart';

class SakitPage extends StatefulWidget {
  final String role;

  const SakitPage({super.key, required this.role});

  @override
  State<SakitPage> createState() => _SakitPageState();
}

class _SakitPageState extends State<SakitPage> {
  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();
  int expandedIndex = -1;

  List<Map<String, String>> dataSakit = [
    {
      "nama": "Han Jisung",
      "tanggal": "11 November 2025",
      "email": "Hanji@gmail.com",
      "jenis": "Sakit",
      "file": "surat_sakit.pdf",
    },
  ];

  String keyword = "";

  // ============================================================
  // POPUP TERIMA
  // ============================================================
  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pengajuan telah diterima",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // POPUP KONFIRMASI TOLAK
  // ============================================================
  void showRejectConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Apakah Anda yakin ingin menolak?",
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
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Tidak",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showRejectSuccess(context);
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Color(0xFF36546C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text("Ya",
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

  // ============================================================
  // POPUP TOLAK SUKSES
  // ============================================================
  void showRejectSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 45),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Pengajuan telah ditolak",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text("OK", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          Expanded(child: SakitList()),
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
                onTap: () => Navigator.pop(context),
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

  // TAB BAR + LOGIKA PINDAH HALAMAN
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
                    _tabButton("Pengajuan", 0),
                    _tabButton("Rekapan", 1),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 1) {
            String role = widget.role; // role dari halaman sebelumnya

            // ⬇ jika role tidak ditemukan, default ke murid
            if (role != "Admin" && role != "Karyawan" && role != "Murid") {
              role = "Murid";
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RekapanAdminSakitPage(role: role),
              ),
            );
            return;
          }

          // Untuk tab pengajuan
          setState(() => selectedTab = index);
        },
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedTab == index ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 16,
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
                onChanged: (value) =>
                    setState(() => keyword = value.toLowerCase()),
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

  // LIST IZIN SAKIT
  Widget SakitList() {
    var filtered = dataSakit
        .where((e) => e["nama"]!.toLowerCase().contains(keyword))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return SakitCard(filtered[index], index);
      },
    );
  }

  Widget SakitCard(Map<String, String> item, int index) {
    bool isExpanded = expandedIndex == index;

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
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFFDA3B26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["nama"]!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Periode Izin :",
                        style: TextStyle(color: Colors.black54)),
                    Text(
                      "${item["tanggal"]} s.d ${item["tanggal"]}",
                      style: const TextStyle(
                          color: Color(0xFFDA3B26),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA954),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Proses",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? -1 : index;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
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
          if (isExpanded) ...[
            const SizedBox(height: 15),
            detailRow("Alamat Email :", item["email"]!),
            detailRow("Tanggal :", item["tanggal"]!),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFDA3B26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.white),
                    SizedBox(width: 8),
                    Text("File", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => showRejectConfirm(context),
                  child: buildActionButton("TOLAK", Colors.red),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showSuccessPopup(context),
                  child: buildActionButton("TERIMA", const Color(0xFF36546C)),
                ),
              ],
            )
          ]
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
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget buildActionButton(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
