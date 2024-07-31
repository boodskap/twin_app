import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  final width;
  final height;
  const DottedDivider({super.key, this.width = 35, this.height = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, 
      height: height, 
      child: CustomPaint(
        painter: DottedLinePainter(),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black 
      ..strokeWidth = 1 
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double dashWidth = 5; 
    final double dashSpace = 2; 
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
