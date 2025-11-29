import 'package:flutter/material.dart';
import 'package:languo/screen/edit_profile.dart';
import 'qr_scanner_screen.dart';

class EmployeeDetailScreen extends StatefulWidget {
  const EmployeeDetailScreen({Key? key}) : super(key: key);

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  int _currentIndex = 0;

  final Map<String, dynamic> employeeData = {
    'name': 'Kelas Mandarin',
    'date': 'Sen, 1 Nov 2025',
    'time': '08:00 - 18:00',
    'meetings': [
      {
        'id': 1,
        'title': 'Pertemuan 1',
        'materials': [
          'Pengenalan Dasar',
          'Kosakata Dasar',
          'Tata Bahasa',
          'Percakapan dan Latihan Mendengar',
          'Menulis dan Membaca',
          'Pengujian Materi'
        ]
      }
    ]
  };

  @override
  Widget build(BuildContext context) {
    final materials = (employeeData['meetings'] as List)
        .first['materials'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF36546C),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),

              Column(
                children: [
                  // Header judul
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            'Detail',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 150, // ← DIPENDEKIN
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                employeeData['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                employeeData['date'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, // ← BOLD
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            employeeData['time'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black87,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12, // ← lebih soft
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Merah
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE75636),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Pertemuan 1',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Isi Materi
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Materi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // List Materi
                                ...materials.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final material = entry.value;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.grey.withOpacity(0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${idx + 1}.',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            material,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold, // ← BOLD
                                              color: Colors.black87,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bottomItem(Icons.home, "Beranda", _currentIndex == 0, () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              }),
              const SizedBox(width: 80),
              _bottomItem(
                  Icons.person_outline, "Profile", _currentIndex == 2, () {
                setState(() => _currentIndex = 2);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              }),
            ],
          ),
        ),

        // FAB
        Positioned(
          top: -20,
          child: GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              );

              if (!mounted) return;

              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("QR Code berhasil dipindai: $result"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF36546C),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomItem(
      IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF36546C) : Colors.grey[400],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF36546C) : Colors.grey[400],
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
