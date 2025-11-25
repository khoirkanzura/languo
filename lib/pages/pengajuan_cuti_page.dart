import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/cuti_service.dart';

class PengajuanCutiPage extends StatefulWidget {
  const PengajuanCutiPage({super.key});

  @override
  State<PengajuanCutiPage> createState() => _PengajuanCutiPageState();
}

class _PengajuanCutiPageState extends State<PengajuanCutiPage> {
  int selectedTab = 0;

  String? selectedPerihal;
  DateTime? startDate;
  DateTime? endDate;
  File? lampiran;
  final picker = ImagePicker();
  final keteranganController = TextEditingController();

  List<String> perihalList = [
    "Sakit Keras",
    "Menikah",
    "Duka",
    "Melahirkan",
    "Lainnya",
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                    "Cuti",
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
          Transform.translate(
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
          ),
          Expanded(
            child: selectedTab == 0
                ? _buildForm()
                : const Center(child: Text("Halaman Rekapan Cuti")),
          )
        ],
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

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text("Perihal Cuti",
              style: TextStyle(
                  color: Color(0xFF7F7F7F), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedPerihal,
                hint: const Text("Pilih Perihal Cuti"),
                items: perihalList
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => selectedPerihal = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                      ? "Tanggal Mulai"
                      : "${startDate!.day} ${_monthName(startDate!.month)} ${startDate!.year}"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: pickEndDate,
                  child: _dateBox(endDate == null
                      ? "Tanggal Selesai"
                      : "${endDate!.day} ${_monthName(endDate!.month)} ${endDate!.year}"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: pickLampiran,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  lampiran == null ? "Upload Lampiran" : "Lampiran Terpilih",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
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
          GestureDetector(
            onTap: _kirimPengajuan,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2B3541),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Center(
                child: Text(
                  "Kirim",
                  style: TextStyle(
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

  Future<void> _kirimPengajuan() async {
    if (selectedPerihal == null ||
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

      await CutiService().kirimPengajuan(
        userId: user.uid,
        startDate: startDate!,
        endDate: endDate!,
        keterangan: keteranganController.text,
        lampiran: lampiran!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengajuan cuti berhasil dikirim!")),
      );

      setState(() {
        selectedPerihal = null;
        startDate = null;
        endDate = null;
        lampiran = null;
        keteranganController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim pengajuan: $e")),
      );
    }
  }

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
