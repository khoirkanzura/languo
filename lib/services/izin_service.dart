import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class IzinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload lampiran ke Firebase Storage
  Future<String> uploadLampiran(File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = _storage.ref().child("lampiran_izin/$fileName");

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  /// Kirim pengajuan izin ke Firestore
  Future<void> kirimPengajuan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String keterangan,
    required File lampiran, required String perihal,
  }) async {
    // Upload gambar ke Storage
    String urlLampiran = await uploadLampiran(lampiran);

    // Konsisten pakai koleksi: "pengajuan_izin"
    await _firestore.collection("pengajuan_izin").add({
      "userId": userId,
      "tanggalMulai": Timestamp.fromDate(startDate),
      "tanggalSelesai": Timestamp.fromDate(endDate),
      "keterangan": keterangan,
      "lampiranUrl": urlLampiran,
      "status": "Proses",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Ambil rekapan izin berdasarkan user
  Stream<QuerySnapshot> getRekapanIzin(String uid) {
    return _firestore
        .collection("pengajuan_izin")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
