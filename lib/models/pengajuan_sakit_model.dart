import 'package:cloud_firestore/cloud_firestore.dart';

class PengajuanSakitModel {
  final String sakitId;
  final String userId;
  final String userName;
  final String userRole;
  final DateTime startDate;
  final DateTime endDate;
  final String keterangan;
  final String? lampiranUrl;
  final String? fileName;
  final String status;
  final DateTime createdAt;

  PengajuanSakitModel({
    required this.sakitId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.startDate,
    required this.endDate,
    required this.keterangan,
    this.lampiranUrl,
    this.fileName,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Model -> Firestore JSON
  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "user_name": userName,
      "user_role": userRole,
      "start_date": Timestamp.fromDate(startDate),
      "end_date": Timestamp.fromDate(endDate),
      "keterangan": keterangan,
      "lampiran_url": lampiranUrl,
      "file_name": fileName,
      "status": status,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  /// Firestore -> Model
  factory PengajuanSakitModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return PengajuanSakitModel(
      sakitId: doc.id,
      userId: data["user_id"],
      userName: data["user_name"],
      userRole: data["user_role"],
      startDate: (data["start_date"] as Timestamp).toDate(),
      endDate: (data["end_date"] as Timestamp).toDate(),
      keterangan: data["keterangan"],
      lampiranUrl: data["lampiran_url"],
      fileName: data["file_name"],
      status: data["status"],
      createdAt: (data["created_at"] as Timestamp).toDate(),
    );
  }
}
