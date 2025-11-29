import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/izin_service.dart';

class PengajuanIzinPage extends StatefulWidget {
  const PengajuanIzinPage({super.key});

  @override
  State<PengajuanIzinPage> createState() => _PengajuanIzinPageState();
}

class _PengajuanIzinPageState extends State<PengajuanIzinPage> {
  int selectedTab = 0;

  DateTime? startDate;
  DateTime? endDate;
  File? lampiran;

  final picker = ImagePicker();
  final keteranganController = TextEditingController();
  final perihalController = TextEditingController();

  bool sudahTerkirim = false;

  // ========================= PICKER =========================

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? (startDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  Future<void> pickLampiran() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => lampiran = File(img.path));
  }

  void removeLampiran() {
    setState(() => lampiran = null);
  }

  // ========================= FORMAT BULAN =========================

  String _monthName(int m) {
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
    return bulan[m - 1];
  }

  // ========================= POPUP KONFIRMASI (SUDAH ADA BOLD) =========================

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Center(
          child: Container(
            width: 320,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ==================== Teks Bold ====================
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: "Apakah anda yakin\nuntuk mengirim?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800, // BOLD
                        ),
                      ),
                    ),
                    // =====================================================

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _kirimPengajuan();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1666A9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Ya",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF05454),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Tidak",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ========================= POPUP SUKSES =========================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Center(
          child: Container(
            width: 320,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 3),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Pengajuan Telah\nDiterima",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ========================= KIRIM KE SERVICE =========================

  Future<void> _kirimPengajuan() async {
    if (perihalController.text.isEmpty ||
        startDate == null ||
        endDate == null ||
        lampiran == null ||
        keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua field!")),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User tidak ditemukan!")),
        );
        return;
      }

      await IzinService().kirimPengajuan(
        userId: user.uid,
        startDate: startDate!,
        endDate: endDate!,
        keterangan: keteranganController.text,
        lampiran: lampiran!,
        perihal: perihalController.text,
      );

      setState(() {
        sudahTerkirim = true;
        perihalController.clear();
        startDate = null;
        endDate = null;
        lampiran = null;
        keteranganController.clear();
      });

      Future.delayed(const Duration(milliseconds: 200), () {
        _showSuccessDialog();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim pengajuan: $e")),
      );
    }
  }

  // ========================= BUILD UI =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: selectedTab == 0
                ? _buildForm()
                : const Center(child: Text("Halaman Rekapan Izin")),
          ),
        ],
      ),
    );
  }

  // ------------------------- HEADER -------------------------

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFF36546C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Izin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------- TABS -------------------------

  Widget _buildTabs() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        height: 55,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            _tabButton("Pengajuan", 0),
            _tabButton("Rekapan", 1),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            gradient: selectedTab == index
                ? const LinearGradient(
                    colors: [Colors.deepOrange, Colors.redAccent],
                  )
                : null,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selectedTab == index ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------- FORM -------------------------

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          // PERIHAL
          _sectionTitle("Perihal Izin"),
          _textFieldPerihal(),

          const SizedBox(height: 20),

          // TANGGAL
          _sectionTitle("Tanggal"),
          _tanggalPicker(),

          const SizedBox(height: 20),

          // LAMPIRAN
          _sectionTitle("Lampiran"),
          _uploadLampiran(),

          const SizedBox(height: 20),

          // KETERANGAN
          _sectionTitle("Keterangan"),
          _keteranganBox(),

          const SizedBox(height: 25),

          _kirimButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF7F7F7F),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // PERIHAL TEXTFIELD
  Widget _textFieldPerihal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: perihalController,
        decoration: const InputDecoration(
          hintText: "Tulis perihal izin...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // TANGGAL
  Widget _tanggalPicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: pickStartDate,
            child: _dateBox(
              startDate == null
                  ? "Tanggal Mulai"
                  : "${startDate!.day} ${_monthName(startDate!.month)} ${startDate!.year}",
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: pickEndDate,
            child: _dateBox(
              endDate == null
                  ? "Tanggal Selesai"
                  : "${endDate!.day} ${_monthName(endDate!.month)} ${endDate!.year}",
            ),
          ),
        ),
      ],
    );
  }

  // LAMPIRAN
  Widget _uploadLampiran() {
    return Column(
      children: [
        GestureDetector(
          onTap: pickLampiran,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                "Upload Lampiran",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (lampiran != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file,
                    size: 22, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    lampiran!.path.split("/").last,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: removeLampiran,
                  child: const Icon(
                    Icons.close,
                    color: Colors.black54,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }

  // KETERANGAN
  Widget _keteranganBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: keteranganController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: "Tulis keterangan...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // BUTTON KIRIM
  Widget _kirimButton() {
    return GestureDetector(
      onTap: sudahTerkirim ? null : _showConfirmDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sudahTerkirim ? Colors.blue.shade300 : const Color(0xFF2B3541),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            sudahTerkirim ? "Sudah Terkirim" : "Kirim",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // DATE BOX UI
  Widget _dateBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text),
          const Icon(Icons.calendar_today, size: 18),
        ],
      ),
    );
  }
}