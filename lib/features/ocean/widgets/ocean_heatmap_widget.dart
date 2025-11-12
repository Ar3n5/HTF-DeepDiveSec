import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Heatmap widget for displaying ocean data intensity across regions
class OceanHeatmap extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final String unit;
  final List<Color> colorScale;

  const OceanHeatmap({
    super.key,
    required this.title,
    required this.data,
    this.unit = '',
    this.colorScale = const [
      Color(0xFF0000FF), // Blue (cold)
      Color(0xFF00FFFF), // Cyan
      Color(0xFF00FF00), // Green
      Color(0xFFFFFF00), // Yellow
      Color(0xFFFF0000), // Red (hot)
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (data.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              'No heatmap data available',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    // Calculate min/max for color scaling
    final values = data.map((d) => (d['value'] as num).toDouble()).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);

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
                Icon(Icons.grid_on, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Heatmap grid
            SizedBox(
              height: 300,
              child: CustomPaint(
                painter: _HeatmapPainter(
                  data: data,
                  minValue: minValue,
                  maxValue: maxValue,
                  colorScale: colorScale,
                ),
                child: Container(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Color scale legend
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colorScale,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${maxValue.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${minValue.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.take(5).map((item) {
                final region = item['region'] ?? item['name'] ?? 'Unknown';
                final value = (item['value'] as num).toDouble();
                final color = _getColorForValue(value, minValue, maxValue);
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$region: ${value.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
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

  Color _getColorForValue(double value, double min, double max) {
    if (max == min) return colorScale[2]; // Middle color
    
    final normalized = (value - min) / (max - min);
    final index = (normalized * (colorScale.length - 1)).clamp(0, colorScale.length - 1);
    final lowerIndex = index.floor();
    final upperIndex = (lowerIndex + 1).clamp(0, colorScale.length - 1);
    final t = index - lowerIndex;
    
    return Color.lerp(colorScale[lowerIndex], colorScale[upperIndex], t)!;
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double minValue;
  final double maxValue;
  final List<Color> colorScale;

  _HeatmapPainter({
    required this.data,
    required this.minValue,
    required this.maxValue,
    required this.colorScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Determine grid dimensions
    final gridSize = math.sqrt(data.length).ceil();
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    for (var i = 0; i < data.length; i++) {
      final row = i ~/ gridSize;
      final col = i % gridSize;
      final value = (data[i]['value'] as num).toDouble();
      
      final normalized = (value - minValue) / (maxValue - minValue);
      final colorIndex = (normalized * (colorScale.length - 1)).clamp(0, colorScale.length - 1);
      final lowerIndex = colorIndex.floor();
      final upperIndex = (lowerIndex + 1).clamp(0, colorScale.length - 1);
      final t = colorIndex - lowerIndex;
      
      final color = Color.lerp(colorScale[lowerIndex], colorScale[upperIndex], t)!;
      
      final rect = Rect.fromLTWH(
        col * cellWidth,
        row * cellHeight,
        cellWidth - 1,
        cellHeight - 1,
      );
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

