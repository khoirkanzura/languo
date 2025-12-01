import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class IzinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, String>> uploadLampiran({
    required Uint8List bytes,
    required String fileName,
    required String userId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cleanFileName = fileName.replaceAll(" ", "_");

    final storagePath = 'izin_lampiran/$userId/${timestamp}_$cleanFileName';
    final ref = _storage.ref().child(storagePath);

    // Tentukan content type berdasarkan ekstensi file
    String ext = fileName.split(".").last.toLowerCase();
    String contentType = "application/octet-stream";

    final contentTypes = {
      "jpg": "image/jpeg",
      "jpeg": "image/jpeg",
      "png": "image/png",
      "pdf": "application/pdf",
      "doc": "application/msword",
      "docx":
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    };

    contentType = contentTypes[ext] ?? "application/octet-stream";

    try {
      final metadata = SettableMetadata(contentType: contentType);

      await ref.putData(bytes, metadata);
      final url = await ref.getDownloadURL();

      return {
        'lampiranUrl': url,
        'storagePath': storagePath,
      };
    } on FirebaseException catch (e) {
      debugPrint("Firebase Storage Upload Error: ${e.code} - ${e.message}");
      rethrow;
    }
  }

  /// Kirim pengajuan izin ke Firestore
  Future<void> kirimPengajuan({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required String keterangan,
    required Uint8List lampiranBytes,
    required String fileName, 
    required String perihal,
  }) async {
    try {
      // Ambil profile user login
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      final userName = userDoc.data()?["user_name"] ?? "-";
      final userRole = userDoc.data()?["user_role"] ?? "-";
    
      final uploadResult = await uploadLampiran(
        bytes: lampiranBytes,
        fileName: fileName,
        userId: userId,
      );

      // Simpan ke Firestore
      await _firestore.collection("pengajuan_izin").add({
        "userId": userId,
        "userName": userName,
        "userRole": userRole,
        "perihal": perihal,
        "tanggalMulai": Timestamp.fromDate(startDate),
        "tanggalSelesai": Timestamp.fromDate(endDate),
        "keterangan": keterangan,
        "lampiranUrl": uploadResult['lampiranUrl'],
        "storagePath": uploadResult['storagePath'],
        "status": "Diajukan",
        "createdAt": FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint("Firebase Kirim Pengajuan Error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("General Error in kirimPengajuan: $e");
      rethrow;
    }
  }

  /// Ambil rekapan izin berdasarkan user
  Stream<QuerySnapshot> getRekapanIzin(String uid) {
    return _firestore
        .collection("pengajuan_Izin")
        .where("userId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}
