import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final Function() onSignInTap;

  const RegisterScreen({super.key, required this.onSignInTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showPassword = false;

  int _selectedIndex = 1; // aktif tab Register
  String? selectedRole; // role dropdown

  Future<void> registerUser() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Role terlebih dahulu")),
      );
      return;
    }

    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = cred.user;

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "uid": user.uid,
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "role": selectedRole,
        "created_at": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi Berhasil")),
      );

      await FirebaseAuth.instance.signOut();

      widget.onSignInTap();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ================= HEADER =================
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
          ),

          // ================= TAB SWITCHER =================
          Transform.translate(
            offset: const Offset(0, -45),
            child: Container(
              height: 55,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(40),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double tabWidth = constraints.maxWidth / 2;

                  return Stack(
                    children: [
                      AnimatedPositioned(
                        left: _selectedIndex == 0 ? 0 : tabWidth,
                        duration: const Duration(milliseconds: 250),
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
                            child: _tabButton(
                              "Sign In",
                              _selectedIndex == 0,
                              widget.onSignInTap,
                            ),
                          ),
                          Expanded(
                            child: _tabButton(
                              "Register",
                              _selectedIndex == 1,
                              () {},
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

          // ================= CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  const Text(
                    "Membuat Akun",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // NAMA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _inputField(
                      icon: Icons.person_outline,
                      hint: "Nama",
                      controller: nameController,
                    ),
                  ),

                  // EMAIL
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _inputField(
                      icon: Icons.email_outlined,
                      hint: "Email",
                      controller: emailController,
                    ),
                  ),

                  // PASSWORD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _inputField(
                      icon: Icons.lock_outline,
                      hint: "Password",
                      controller: passwordController,
                      obscure: !showPassword,
                      isPassword: true,
                    ),
                  ),

                  // ROLE DROPDOWN
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade600,
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedRole,
                                isExpanded: true,
                                hint: const Text("Role",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey)),
                                items: const [
                                  DropdownMenuItem(
                                    value: "karyawan",
                                    child: Text("Karyawan"),
                                  ),
                                  DropdownMenuItem(
                                    value: "murid",
                                    child: Text("Murid"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => selectedRole = value);
                                },
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON REGISTER FULL WIDTH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: registerUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF2B3541),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _tabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => showPassword = !showPassword),
                )
              : null,
        ),
      ),
    );
  }
}
