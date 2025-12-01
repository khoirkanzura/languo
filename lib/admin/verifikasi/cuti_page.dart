import 'package:flutter/material.dart';

class CutiPage extends StatefulWidget {
  const CutiPage({super.key});

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  int selectedTab = 0;
  TextEditingController searchController = TextEditingController();
  int expandedIndex = -1;

  List<Map<String, String>> dataCuti = [
    {
      "nama": "GERLY VAEYUNGFAN",
      "mulai": "18 Nov 2025",
      "selesai": "20 Nov 2025",
      "email": "gerlyvaeyungfan@gmail.com",
      "alasan": "Mengambil Cuti Tahunan",
      "sisa": "3 hari",
      "tanggal": "11 November 2025"
    },
    {
      "nama": "ISMI ATIKA",
      "mulai": "10 Nov 2025",
      "selesai": "12 Nov 2025",
      "email": "ismiatika@gmail.com",
      "alasan": "Urusan Keluarga",
      "sisa": "1 hari",
      "tanggal": "7 November 2025"
    },
    {
      "nama": "NITA ANGGRAINI",
      "mulai": "5 Nov 2025",
      "selesai": "6 Nov 2025",
      "email": "nitaangg@gmail.com",
      "alasan": "Sakit",
      "sisa": "2 hari",
      "tanggal": "3 November 2025"
    },
  ];

  String keyword = "";

  // ====================== POPUP TERIMA ======================
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

  // ====================== POPUP CONFIRM TOLAK (MODIFIKASI) ======================
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
                const SizedBox(height: 10),
                const Text(
                  "Apakah Anda yakin\ningin menolak?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TIDAK
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
                          child: const Text(
                            "Tidak",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(221, 243, 239, 239)),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // YA
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
                          child: const Text(
                            "Ya",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ====================== POPUP TOLAK SUKSES ======================
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

  // ====================== UI ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          header(),
          tabBar(),
          searchBar(),
          Expanded(child: cutiList()),
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 20, top: 35),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Cuti  <  Karyawan",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB BAR
  Widget tabBar() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3F5),
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
                    width: tabWidth,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFC6D51), Color(0xFFEA5A3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                Row(
                  children: [
                    tabButton("Pengajuan", 0),
                    tabButton("Rekapan", 1),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget tabButton(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedTab == index ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 15,
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

  // LIST CUTI
  Widget cutiList() {
    var filtered = dataCuti
        .where((e) => e["nama"]!.toLowerCase().contains(keyword))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return cutiCard(filtered[index], index);
      },
    );
  }

  // ITEM CARD
  Widget cutiCard(Map<String, String> item, int index) {
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
          // HEADER CARD
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
                    const Text("Periode Cuti :",
                        style: TextStyle(color: Colors.black54)),
                    Text(
                      "${item["mulai"]} s.d ${item["selesai"]}",
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

          // EXPANDED DETAIL
          if (isExpanded) ...[
            const SizedBox(height: 15),

            detailRow("Alamat Email :", item["email"]!),
            detailRow("Alasan :", item["alasan"]!),
            detailRow("Sisa cuti :", item["sisa"]!),
            detailRow("Tanggal :", item["tanggal"]!),

            const SizedBox(height: 15),

            // FILE BUTTON
            GestureDetector(
              onTap: () {
                print("File dibuka");
              },
              child: Container(
                width: double.infinity,
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
                // TOLAK
                GestureDetector(
                  onTap: () => showRejectConfirm(context),
                  child: buildActionButton("TOLAK", Colors.red),
                ),
                const SizedBox(width: 8),

                // TERIMA
                GestureDetector(
                  onTap: () {
                    showSuccessPopup(context);
                  },
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
          Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 5),
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
