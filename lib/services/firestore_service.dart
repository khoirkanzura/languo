import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/absensi_model.dart';
import '../models/user_model.dart'; 
import '../models/qr_code_model.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================================
  // 1. FUNGSI ABSENSI (DIPAKAI TIM 2 & 4)
  // ==========================================================
  
  // TELAH DIMODIFIKASI: HANYA MENGAMBIL scannedUserId
  Future<void> recordAbsensi(int scannedUserId) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Operator tidak terautentikasi.');
    }

    // --- LOGIKA WAKTU (Check-in/Check-out Otomatis 18:00) ---
    final checkInTime = DateTime.now(); // Waktu scan aktual

    final checkOutTargetTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      18, // Jam 18:00
      0,
      0,
    );
    final finalCheckOutTime = checkOutTargetTime;

    // --- END LOGIKA WAKTU ---

    final absensiData = AbsensiModel(
      userId: scannedUserId,
      // qrId: scannedQrId, <-- TELAH DIHAPUS
      operatorUid: currentUser.uid,
      checkInTime: Timestamp.fromDate(checkInTime), 
      checkOutTime: Timestamp.fromDate(finalCheckOutTime), 
      status: 'check_in', 
      absensiStatus: 'Valid', 
    );

    final docId = absensiData.documentId;

    try {
      await _db.collection('absensi').doc(docId).set(absensiData.toMap());
      print('Absensi berhasil dicatat: $docId');

    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Gagal mencatat: Peserta sudah melakukan absensi (Duplikat).');
      }
      throw Exception('Gagal mencatat absensi: ${e.message}');
    } catch (e) {
      rethrow;
    }
}

  // MENGAMBIL ABSENSI HARI INI (BARU)
  Future<AbsensiModel?> getTodayAbsensi(int userId) async {
    try {
        final today = DateTime.now();
        // Membentuk Document ID berdasarkan tanggal hari ini (USER_ID_YYYYMMDD)
        final dateString = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
        final docId = '${userId}_$dateString';

        final doc = await _db.collection('absensi').doc(docId).get();

        if (doc.exists) {
            return AbsensiModel.fromMap(doc.data()!, doc.id);
        }
        return null;
    } catch (e) {
        print('Error getting today absensi: $e');
        return null;
    }
  }

  // ==========================================================
  // 2. FUNGSI USERS (DIPAKAI TIM 1 & 4)
  // ==========================================================

  Future<void> saveUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
}

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['user_role'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  // MENDAPATKAN USER BERDASARKAN USER_ID (BARU)
  Future<UserModel?> getUserDataByUserId(int userId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        // Mengirim data map dan UID Firebase (doc.id)
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user data by user ID: $e');
      return null;
    }
  }

  // ==========================================================
  // 3. FUNGSI QR CODE (DIPAKAI TIM 2 - VALIDASI AWAL)
  // ==========================================================

  Future<QRCodeModel?> verifyQRCodeValue(String qrValue) async {
    try {
      final doc = await _db.collection('qr_code').doc(qrValue).get();

      if (doc.exists) {
        return QRCodeModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error verifying QR Code: $e');
      return null;
    }
  }
}