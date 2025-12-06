import 'package:cloud_firestore/cloud_firestore.dart';

class PengajuanCutiModel {
  final String cutiId;
  final String userId;
  final String userName;
  final String userRole;
  final String alasan;
  final DateTime startDate;
  final DateTime endDate;
  final String keterangan;
  final String? lampiranUrl;
  final String? fileName;
  final num sisaCutiSaatPengajuan;
  final String status;
  final DateTime createdAt;

  PengajuanCutiModel({
    required this.cutiId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.alasan,
    required this.startDate,
    required this.endDate,
    required this.keterangan,
    this.lampiranUrl,
    this.fileName,
    required this.sisaCutiSaatPengajuan,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Model -> Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "user_name": userName,
      "user_role": userRole,
      "alasan": alasan,
      "start_date": Timestamp.fromDate(startDate),
      "end_date": Timestamp.fromDate(endDate),
      "keterangan": keterangan,
      "lampiran_url": lampiranUrl,
      "file_name": fileName,
      "sisa_cuti_saat_pengajuan": sisaCutiSaatPengajuan,
      "status": status,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  /// Firestore -> Model
  factory PengajuanCutiModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return PengajuanCutiModel(
      cutiId: doc.id,
      userId: data["user_id"],
      userName: data["user_name"],
      userRole: data["user_role"],
      alasan: data["alasan"],
      startDate: (data["start_date"] as Timestamp).toDate(),
      endDate: (data["end_date"] as Timestamp).toDate(),
      keterangan: data["keterangan"],
      lampiranUrl: data["lampiran_url"],
      fileName: data["file_name"],
      sisaCutiSaatPengajuan: data["sisa_cuti_saat_pengajuan"],
      status: data["status"],
      createdAt: (data["created_at"] as Timestamp).toDate(),
    );
  }
}
