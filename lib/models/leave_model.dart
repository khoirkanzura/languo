import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveModel {
  final String? leaveId;
  final DocumentReference userRef;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String? lampiranUrl;
  final DateTime createdAt;

  LeaveModel({
    this.leaveId,
    required this.userRef,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = "Proses",
    this.lampiranUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "user_ref": userRef,
      "leave_type": leaveType,
      "start_date": Timestamp.fromDate(startDate),
      "end_date": Timestamp.fromDate(endDate),
      "reason": reason,
      "status": status,
      "lampiran_url": lampiranUrl,
      "created_at": Timestamp.fromDate(createdAt),
    };
  }

  /// Convert Firestore -> Model
  factory LeaveModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return LeaveModel(
      leaveId: doc.id, // GET DOCUMENT ID HERE 👇
      userRef: data["user_ref"],
      leaveType: data["leave_type"],
      startDate: (data["start_date"] as Timestamp).toDate(),
      endDate: (data["end_date"] as Timestamp).toDate(),
      reason: data["reason"],
      status: data["status"],
      lampiranUrl: data["lampiran_url"],
      createdAt: (data["created_at"] as Timestamp).toDate(),
    );
  }
}
