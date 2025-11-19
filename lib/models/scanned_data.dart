class ScannedData {
  final String data;
  final String scannedBy;
  final DateTime scannedAt;

  ScannedData({
    required this.data,
    required this.scannedBy,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'data': data,
      'scannedBy': scannedBy,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }

  factory ScannedData.fromMap(Map<String, dynamic> map) {
    return ScannedData(
      data: map['data'] ?? '',
      scannedBy: map['scannedBy'] ?? '',
      scannedAt: DateTime.parse(map['scannedAt']),
    );
  }
}