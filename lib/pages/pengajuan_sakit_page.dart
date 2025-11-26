import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/sakit_service.dart';

class PengajuanSakitPage extends StatefulWidget {
  const PengajuanSakitPage({super.key});

  @override
  State<PengajuanSakitPage> createState() => _PengajuanSakitPageState();
}

class _PengajuanSakitPageState extends State<PengajuanSakitPage> {
  final _sakitService = SakitService();
  final _auth = FirebaseAuth.instance;

  int selectedTab = 0;
  DateTime? startDate;
  DateTime? endDate;
  File? lampiran;
  final picker = ImagePicker();
  final TextEditingController keteranganController = TextEditingController();

  bool isSubmitted = false; // <-- status tombol Kirim

  // ======================
  // PILIH TANGGAL
  // ======================
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

  // ======================
  // UPLOAD LAMPIRAN
  // ======================
  Future<void> pickLampiran() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => lampiran = File(img.path));
  }

  void removeLampiran() {
    setState(() => lampiran = null);
  }

  // ======================
  // POPUP KONFIRMASI
  // ======================
  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
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
                const Text(
                  "Apakah anda yakin\nuntuk mengirim?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),

                /// TOMBOL YA & TIDAK — SAMA BESAR
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          submitForm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1666A9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
        );
      },
    );
  }

  // ======================
  // POPUP SUKSES
  // ======================
  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        size: 20, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Icon(Icons.check, size: 40, color: Colors.green),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Pengajuan Telah Diterima",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================
  // KIRIM DATA
  // ======================
  Future<void> submitForm() async {
    if (startDate == null || endDate == null) {
      return _showMessage("Tanggal belum dipilih");
    }
    if (lampiran == null) {
      return _showMessage("Lampiran belum diupload");
    }
    if (keteranganController.text.isEmpty) {
      return _showMessage("Keterangan masih kosong");
    }

    try {
      String userId = _auth.currentUser?.uid ?? "unknown";

      await _sakitService.kirimPengajuan(
        userId: userId,
        startDate: startDate!,
        endDate: endDate!,
        keterangan: keteranganController.text,
        lampiran: lampiran!,
      );

      // Tampilkan popup sukses
      showSuccessDialog();

      // Reset form
      setState(() {
        isSubmitted = true;
        startDate = null;
        endDate = null;
        lampiran = null;
        keteranganController.clear();
      });
    } catch (e) {
      _showMessage("Gagal mengirim pengajuan: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

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

  // ======================
  // UI HALAMAN
  // ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER ATAS
          Container(
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
                      child:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Sakit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TAB ATAS
          Transform.translate(
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTab = 0),
                              child: Center(
                                child: Text(
                                  "Pengajuan",
                                  style: TextStyle(
                                    color: selectedTab == 0
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedTab = 1),
                              child: Center(
                                child: Text(
                                  "Rekapan",
                                  style: TextStyle(
                                    color: selectedTab == 1
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: selectedTab == 0
                ? _buildForm()
                : const Center(
                    child: Text("Buka halaman Rekapan untuk melihat data")),
          )
        ],
      ),
    );
  }

  // ======================
  // FORM
  // ======================
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          const Text("Tanggal",
              style: TextStyle(
                  color: Color(0xFF7F7F7F), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: pickStartDate,
                  child: _dateBox(startDate == null
                      ? "Pilih Tanggal"
                      : "${startDate!.day} ${_monthName(startDate!.month)} ${startDate!.year}"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: pickEndDate,
                  child: _dateBox(endDate == null
                      ? "Pilih Tanggal"
                      : "${endDate!.day} ${_monthName(endDate!.month)} ${endDate!.year}"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // =========================
          // UPLOAD LAMPIRAN — SUDAH DIBENARKAN
          // =========================
          const Text("Lampiran",
              style: TextStyle(
                  color: Color(0xFF7F7F7F), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          // Tombol Upload selalu tampil
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
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Jika ada file → tampilkan card
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
                    child: const Icon(Icons.close,
                        color: Colors.black54, size: 20),
                  )
                ],
              ),
            ),

          const SizedBox(height: 20),

          const Text("Keterangan",
              style: TextStyle(
                  color: Color(0xFF7F7F7F), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          Container(
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
          ),

          const SizedBox(height: 25),

          // ======================
          // TOMBOL KIRIM
          // ======================
          GestureDetector(
            onTap: isSubmitted ? null : _showConfirmDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSubmitted
                    ? Colors.blue.shade300
                    : const Color(0xFF2B3541),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  isSubmitted ? "Sudah Terkirim" : "Kirim",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ======================
  // DATE BOX
  // ======================
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
