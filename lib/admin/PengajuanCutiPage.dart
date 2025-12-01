import 'package:flutter/material.dart';
import 'package:languo/admin/verifikasi/cuti_page.dart';

class PengajuanCutiPage extends StatefulWidget {
  const PengajuanCutiPage({super.key});

  @override
  State<PengajuanCutiPage> createState() => _PengajuanCutiPageState();
}

class _PengajuanCutiPageState extends State<PengajuanCutiPage> {
  int selectedTab = 0; // 0 = Pengajuan, 1 = Rekapan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          const SizedBox(height: 20),
          _menuKaryawan(),
        ],
      ),
    );
  }

  // ========================= HEADER BARU =========================
  Widget _buildHeader() {
    return Container(
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
                child: Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
    );
  }

  // ========================= TAB BAR BARU =========================
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
        onTap: () => setState(() => selectedTab = index),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selectedTab == index ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ========================= MENU KARYAWAN =========================
  Widget _menuKaryawan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CutiPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Karyawan",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CutiPage()),
                  );
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFC6D51),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
