import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CutiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload lampiran ke Firebase Storage
  Future<String> uploadLampiran(File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = _storage.ref().child("lampiran_cuti/$fileName");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// Kirim pengajuan cuti ke Firestore
  Future<void> kirimPengajuan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String keterangan,
    required File lampiran,
  }) async {
    // Upload gambar ke Storage
    String urlLampiran = await uploadLampiran(lampiran);

    // Konsisten pakai koleksi: "pengajuan_cuti"
    await _firestore.collection("pengajuan_cuti").add({
      "userId": userId,
      "tanggalMulai": Timestamp.fromDate(startDate),
      "tanggalSelesai": Timestamp.fromDate(endDate),
      "keterangan": keterangan,
      "lampiranUrl": urlLampiran,
      "status": "Proses",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Ambil rekapan cuti berdasarkan user
  Stream<QuerySnapshot> getRekapanCuti(String uid) {
    return _firestore
        .collection("pengajuan_cuti")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
