import 'package:flutter/material.dart';

class KehadiranPage extends StatefulWidget {
  const KehadiranPage({Key? key}) : super(key: key);

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  String selectedTab = 'Dosen';
  int selectedTabIndex = 0;
  TextEditingController searchController = TextEditingController();
  List<KehadiranData> dosenList = [];
  List<KehadiranData> karyawanList = [];
  List<KehadiranData> filteredList = [];

  @override
  void initState() {
    super.initState();
    loadKehadiranData();
  }

  void loadKehadiranData() {
    // Data Dosen
    dosenList = [
      KehadiranData(
        nama: 'Kartika Tri Juliana',
        email: 'Kartika@gmail.com',
        kelas: 'Kelas Mandarin',
        hariTanggal: 'Jum, 30 Okt 2025',
        masuk: '08:11',
        keluar: '18:05',
        status: 'Tepat Waktu',
        statusMasuk: 'Tepat Waktu',
        statusKeluar: 'Tepat Waktu',
      ),
      KehadiranData(
        nama: 'Kartika Tri Juliana',
        email: 'Kartika@gmail.com',
        kelas: 'Kelas Mandarin',
        hariTanggal: 'Jum, 30 Okt 2025',
        masuk: '08:17',
        keluar: '18:05',
        status: 'Terlambat',
        statusMasuk: 'Terlambat',
        statusKeluar: 'Tepat Waktu',
      ),
      KehadiranData(
        nama: 'Budi Santoso',
        email: 'budi.santoso@gmail.com',
        kelas: 'Kelas Inggris',
        hariTanggal: 'Jum, 30 Okt 2025',
        masuk: '08:05',
        keluar: '17:55',
        status: 'Tepat Waktu',
        statusMasuk: 'Tepat Waktu',
        statusKeluar: 'Tepat Waktu',
      ),
    ];

    // Data Karyawan
    karyawanList = [
      KehadiranData(
        nama: 'Ahmad Fauzi',
        email: 'ahmad.fauzi@company.com',
        kelas: 'Staff Administrasi',
        hariTanggal: 'Jum, 30 Okt 2025',
        masuk: '07:55',
        keluar: '17:00',
        status: 'Tepat Waktu',
        statusMasuk: 'Tepat Waktu',
        statusKeluar: 'Tepat Waktu',
      ),
      KehadiranData(
        nama: 'Siti Nurhaliza',
        email: 'siti.nur@company.com',
        kelas: 'Guru Matematika',
        hariTanggal: 'Jum, 30 Okt 2025',
        masuk: '08:20',
        keluar: '16:50',
        status: 'Terlambat',
        statusMasuk: 'Terlambat',
        statusKeluar: 'Tepat Waktu',
      ),
    ];

    updateFilteredList();
  }

  void updateFilteredList() {
    setState(() {
      List<KehadiranData> currentList = selectedTab == 'Dosen' ? dosenList : karyawanList;
      
      if (searchController.text.isEmpty) {
        filteredList = currentList;
      } else {
        String query = searchController.text.toLowerCase();
        filteredList = currentList
            .where((data) =>
                data.nama.toLowerCase().contains(query) ||
                data.email.toLowerCase().contains(query) ||
                data.kelas.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void filterKehadiran(String query) {
    updateFilteredList();
  }

  void deleteKehadiran(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus data kehadiran ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  KehadiranData itemToRemove = filteredList[index];
                  filteredList.removeAt(index);
                  
                  if (selectedTab == 'Dosen') {
                    dosenList.removeWhere((data) => data == itemToRemove);
                  } else {
                    karyawanList.removeWhere((data) => data == itemToRemove);
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data berhasil dihapus'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          header(),
          tabBar(),
          searchBar(),
          const SizedBox(height: 16),
          Expanded(child: kehadiranList()),
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Center(
                  child: const Text(
                    "Rekapan Kehadiran",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance untuk icon button
            ],
          ),
        ),
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
                  left: selectedTabIndex == 0 ? 0 : tabWidth,
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
                    tabButton("Dosen", 0),
                    tabButton("Karyawan", 1),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget tabButton(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
            selectedTab = label;
            searchController.clear();
            updateFilteredList();
          });
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selectedTabIndex == index ? Colors.white : Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // SEARCH BAR
  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7B8FA7),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: filterKehadiran,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Cari Pengguna....',
            hintStyle: TextStyle(color: Colors.white, fontSize: 15),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: Icon(Icons.search, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  // LIST KEHADIRAN
  Widget kehadiranList() {
    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return KehadiranCard(
          data: filteredList[index],
          onDelete: () => deleteKehadiran(index),
          isKaryawan: selectedTab == 'Karyawan',
        );
      },
    );
  }
}

class KehadiranCard extends StatelessWidget {
  final KehadiranData data;
  final VoidCallback onDelete;
  final bool isKaryawan;

  const KehadiranCard({
    Key? key,
    required this.data,
    required this.onDelete,
    this.isKaryawan = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama, Email dan Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF9E9E9E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              
              // Nama dan Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.nama,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.statusMasuk == 'Terlambat'
                      ? const Color(0xFFEF5350)
                      : const Color(0xFF5CB85C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.statusMasuk == 'Terlambat' ? 'Terlambat' : 'Tepat Waktu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),

          // Info Detail
          _buildInfoRow(isKaryawan ? 'Posisi' : 'Kelas', data.kelas),
          _buildInfoRow('Hari, Tgl', data.hariTanggal),
          _buildInfoRow('Masuk', data.masuk, statusWaktu: data.statusMasuk),
          _buildInfoRow('Keluar', data.keluar, statusWaktu: data.statusKeluar),

          const SizedBox(height: 10),

          // Tombol Hapus
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, size: 16, color: Colors.white),
              label: const Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {String? statusWaktu}) {
    // Tentukan warna berdasarkan status waktu
    Color textColor = Colors.black87;
    FontWeight fontWeight = FontWeight.normal;
    
    if (statusWaktu != null) {
      fontWeight = FontWeight.w600;
      if (statusWaktu == 'Terlambat') {
        textColor = const Color(0xFFEF5350); // Merah untuk terlambat
      } else {
        textColor = const Color(0xFF5CB85C); // Hijau untuk tepat waktu
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KehadiranData {
  final String nama;
  final String email;
  final String kelas;
  final String hariTanggal;
  final String masuk;
  final String keluar;
  final String status;
  final String statusMasuk;
  final String statusKeluar;

  KehadiranData({
    required this.nama,
    required this.email,
    required this.kelas,
    required this.hariTanggal,
    required this.masuk,
    required this.keluar,
    required this.status,
    required this.statusMasuk,
    required this.statusKeluar,
  });

  // Backend Integration - Convert dari JSON
  factory KehadiranData.fromJson(Map<String, dynamic> json) {
    return KehadiranData(
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      kelas: json['kelas'] ?? '',
      hariTanggal: json['hari_tanggal'] ?? '',
      masuk: json['masuk'] ?? '',
      keluar: json['keluar'] ?? '',
      status: json['status'] ?? '',
      statusMasuk: json['status_masuk'] ?? '',
      statusKeluar: json['status_keluar'] ?? '',
    );
  }

  // Backend Integration - Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'email': email,
      'kelas': kelas,
      'hari_tanggal': hariTanggal,
      'masuk': masuk,
      'keluar': keluar,
      'status': status,
      'status_masuk': statusMasuk,
      'status_keluar': statusKeluar,
    };
  }
}