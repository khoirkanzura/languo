import 'package:cloud_firestore/cloud_firestore.dart';

class QRCodeModel {
    final String qrCodeValue; 
    final bool qrStatus;
    final String targetRole; 
    
    final int? generatedBy; 
    final Timestamp? generatedTime;
    final String? description; 

    QRCodeModel({
        required this.qrCodeValue,
        required this.qrStatus,
        required this.targetRole,
        this.generatedBy,
        this.generatedTime,
        this.description,
    });

    factory QRCodeModel.fromMap(Map<String, dynamic> map, String docId) {
        return QRCodeModel(
            qrCodeValue: docId, 
            qrStatus: map['qr_status'] as bool? ?? true,
            targetRole: map['target_role'] as String,
            
            generatedBy: map['generated_by'] as int?,
            generatedTime: map['generated_time'] as Timestamp?,
            description: map['description'] as String?,
        );
    }
}