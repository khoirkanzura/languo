import 'package:flutter/material.dart';

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.orange;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.3, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.3);

    final path2 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.3)
      ..lineTo(size.width * 0.6, size.height * 0.3);

    final path3 = Path()
      ..moveTo(size.width * 0.3, size.height * 0.6)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.7);

    final path4 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.6, size.height * 0.7);

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    // Draw border around scanner area
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white.withOpacity(0.5);

    final borderRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.6,
      height: size.width * 0.6,
    );

    canvas.drawRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}