import 'package:cloud_firestore/cloud_firestore.dart';

class PengajuanIzinModel {
  final String izinId;
  final String userId;
  final String userName;
  final String userRole;
  final String perihal;
  final DateTime startDate;
  final DateTime endDate;
  final String keterangan;
  final String? lampiranUrl;
  final String? fileName;
  final String status;
  final DateTime createdAt;

  PengajuanIzinModel({
    required this.izinId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.perihal,
    required this.startDate,
    required this.endDate,
    required this.keterangan,
    this.lampiranUrl,
    this.fileName,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Model -> Firestore
  Map<String, dynamic> toMap() {
    return {
      "user_id": userId,
      "user_name": userName,
      "user_role": userRole,
      "perihal": perihal,
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
  factory PengajuanIzinModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return PengajuanIzinModel(
      izinId: doc.id,
      userId: data["user_id"],
      userName: data["user_name"],
      userRole: data["user_role"],
      perihal: data["perihal"],
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
