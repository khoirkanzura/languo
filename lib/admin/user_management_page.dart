import 'package:flutter/material.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  // Dummy list user
  List<String> users = ["Ismi Atika", "Budi Santoso", "Siti Aminah"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen User"),
        backgroundColor: const Color(0xFFE75636),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tombol tambah user
            ElevatedButton.icon(
              onPressed: () {
                _showAddUserDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah User"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE75636),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            // List user
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(users[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            users.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk tambah user
  void _showAddUserDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah User"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Masukkan nama user"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    users.add(nameController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }
}
