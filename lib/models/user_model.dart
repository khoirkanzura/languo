class UserModel {
  // PENTING: Menggunakan Firebase UID sebagai kunci utama untuk mapping
  final String uid; 
  
  // Field dari ERD: USERS
  final int userId; // Digunakan sebagai identitas internal (NIM/NIK)
  final String userName;
  final String userEmail;
  final String userRole; // Misalnya: 'Operator', 'Peserta'
  final String? userPhoto; // Optional

  UserModel({
    required this.uid,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.userPhoto,
  });

  // Fungsi untuk mengkonversi model Dart ke format Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_role': userRole,
      'user_photo': userPhoto,
    };
  }

  // Fungsi untuk membuat objek dari data Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      userId: map['user_id'] as int,
      userName: map['user_name'] as String,
      userEmail: map['user_email'] as String,
      userRole: map['user_role'] as String,
      userPhoto: map['user_photo'] as String?,
    );
  }
}