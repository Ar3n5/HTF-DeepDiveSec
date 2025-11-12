import 'package:flutter/material.dart';

/// Simple map widget for showing ocean locations
class OceanMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final String title;

  const OceanMapWidget({
    super.key,
    required this.locations,
    this.title = 'Ocean Locations',
  });

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.map, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!, width: 2),
              ),
              child: CustomPaint(
                painter: _MapPainter(locations: locations),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            ...locations.map((loc) => _buildLocationInfo(loc)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> location) {
    final name = location['name'] ?? 'Unknown';
    final lat = location['latitude'] ?? location['lat'] ?? 0.0;
    final lon = location['longitude'] ?? location['lon'] ?? 0.0;
    final value = location['value'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$name (${lat.toStringAsFixed(1)}°, ${lon.toStringAsFixed(1)}°)',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (value != null)
            Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> locations;

  _MapPainter({required this.locations});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw ocean background
    final oceanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlue[100]!,
          Colors.blue[200]!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);

    // Draw grid lines (latitude/longitude)
    final gridPaint = Paint()
      ..color = Colors.blue[300]!.withOpacity(0.3)
      ..strokeWidth = 1;

    // Vertical lines (longitude)
    for (var i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines (latitude)
    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw location markers
    for (final location in locations) {
      final lat = (location['latitude'] ?? location['lat'] ?? 0.0) as num;
      final lon = (location['longitude'] ?? location['lon'] ?? 0.0) as num;

      // Convert lat/lon to x/y (simplified projection)
      final x = ((lon.toDouble() + 180) / 360) * size.width;
      final y = ((90 - lat.toDouble()) / 180) * size.height;

      // Draw marker
      final markerPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, y), 8, borderPaint);
      canvas.drawCircle(Offset(x, y), 6, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

