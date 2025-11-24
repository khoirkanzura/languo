import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SakitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto/lampiran ke Firebase Storage
  Future<String> uploadLampiran(File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = _storage.ref().child("lampiran_sakit/$fileName");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// Kirim pengajuan sakit ke Firestore
  Future<void> kirimPengajuan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String keterangan,
    required File lampiran,
  }) async {
    // Upload gambar ke Storage
    String urlLampiran = await uploadLampiran(lampiran);

    // Simpan ke Firestore → konsisten pakai "pengajuan_sakit"
    await _firestore.collection("pengajuan_sakit").add({
      "userId": userId,
      "tanggalMulai": Timestamp.fromDate(startDate),
      "tanggalSelesai": Timestamp.fromDate(endDate),
      "keterangan": keterangan,
      "lampiranUrl": urlLampiran,
      "status": "Proses",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Ambil rekapan sakit berdasarkan user
  Stream<QuerySnapshot> getRekapanSakit(String uid) {
    return _firestore
        .collection("pengajuan_sakit")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
