import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom line chart for ocean time series data
class OceanLineChart extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> dataPoints;
  final String unit;
  final Color color;

  const OceanLineChart({
    super.key,
    required this.title,
    required this.dataPoints,
    this.unit = '',
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[800];
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: dataPoints.isEmpty
                  ? Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : CustomPaint(
                      painter: _LineChartPainter(
                        dataPoints: dataPoints,
                        color: color,
                      ),
                      child: Container(),
                    ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Unit: $unit',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> dataPoints;
  final Color color;

  _LineChartPainter({required this.dataPoints, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Extract values
    final values = dataPoints.map((p) {
      final val = p['y'] ?? p['value'] ?? 0;
      return val is num ? val.toDouble() : 0.0;
    }).toList();

    if (values.isEmpty) return;

    final minY = values.reduce(math.min);
    final maxY = values.reduce(math.max);
    final rangeY = maxY - minY;

    if (rangeY == 0) return;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Area fill
    final fillPath = Path();
    final areaGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    fillPath.moveTo(0, size.height);
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minY) / rangeY) * size.height;
      if (i == 0) {
        fillPath.lineTo(x, y);
      } else {
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, areaGradient);

    // Line path
    final linePath = Path();
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minY) / rangeY) * size.height;

      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
    }

    canvas.drawPath(linePath, linePaint);

    // Data points
    final pointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = size.height - ((values[i] - minY) / rangeY) * size.height;
      canvas.drawCircle(Offset(x, y), 5, pointPaint);
      canvas.drawCircle(Offset(x, y), 5, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Bar chart for comparing ocean measurements
class OceanBarChart extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final String unit;
  final List<Color> colors;

  const OceanBarChart({
    super.key,
    required this.title,
    required this.data,
    this.unit = '',
    this.colors = const [
      Colors.blue,
      Colors.teal,
      Colors.cyan,
      Colors.lightBlue,
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.grey[800];
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colors.first, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _BarChartPainter(
                  data: data,
                  colors: colors,
                  isDarkMode: isDark,
                ),
                child: Container(),
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Unit: $unit',
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            // Add legend below
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: data.entries.map((e) {
                final index = data.keys.toList().indexOf(e.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${e.key}: ${e.value.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;
  final bool isDarkMode;

  _BarChartPainter({
    required this.data,
    required this.colors,
    this.isDarkMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final entries = data.entries.toList();
    final maxValue = entries.map((e) => e.value).reduce(math.max);
    final barWidth = size.width / (entries.length * 2);

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final barHeight = (entry.value / maxValue) * size.height * 0.9;
      final x = (i * 2 + 0.5) * barWidth;
      final y = size.height - barHeight;

      // Draw bar with gradient
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth * 0.8, barHeight),
        const Radius.circular(8),
      );

      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors[i % colors.length],
          colors[i % colors.length].withOpacity(0.6),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect.outerRect);

      canvas.drawRRect(rect, paint);

      // Draw label (will be handled by widget context, skip for now to avoid dark mode issues)
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

