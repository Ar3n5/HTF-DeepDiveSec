import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Gauge widget for displaying ocean measurements
class OceanGaugeWidget extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color color;

  const OceanGaugeWidget({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.unit = '',
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _GaugePainter(
                  value: value,
                  min: min,
                  max: max,
                  color: color,
                ),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[800]),
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Range: $min - $max $unit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color color;

  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw value arc with gradient
    final percent = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final sweepAngle = math.pi * 1.5 * percent;

    final gradient = SweepGradient(
      startAngle: math.pi * 0.75,
      endAngle: math.pi * 0.75 + sweepAngle,
      colors: [
        color.withOpacity(0.5),
        color,
      ],
    );

    final valuePaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      sweepAngle,
      false,
      valuePaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);

    // Draw needle
    final needleAngle = math.pi * 0.75 + sweepAngle;
    final needleEnd = Offset(
      center.dx + radius * 0.5 * math.cos(needleAngle),
      center.dy + radius * 0.5 * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center dot
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, dotPaint);

    // Draw min/max labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Min label
    textPainter.text = TextSpan(
      text: min.toStringAsFixed(0),
      style: TextStyle(color: Colors.grey[700], fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - radius - 20, center.dy + radius * 0.5),
    );

    // Max label
    textPainter.text = TextSpan(
      text: max.toStringAsFixed(0),
      style: TextStyle(color: Colors.grey[700], fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx + radius + 5, center.dy + radius * 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

