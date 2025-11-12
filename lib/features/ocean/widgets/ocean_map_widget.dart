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
    // Draw ocean background with gradient
    final oceanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlue[100]!,
          Colors.blue[200]!,
          Colors.blue[300]!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);

    // Draw simplified continents for context
    _drawContinents(canvas, size);

    // Draw grid lines (latitude/longitude)
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical lines (longitude) - every 30 degrees
    for (var i = 0; i <= 12; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines (latitude) - every 30 degrees
    for (var i = 0; i <= 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw location markers with pulse effect
    for (var i = 0; i < locations.length; i++) {
      final location = locations[i];
      final lat = (location['latitude'] ?? location['lat'] ?? 0.0) as num;
      final lon = (location['longitude'] ?? location['lon'] ?? 0.0) as num;

      // Convert lat/lon to x/y (Web Mercator projection)
      final x = ((lon.toDouble() + 180) / 360) * size.width;
      final y = ((90 - lat.toDouble()) / 180) * size.height;

      // Draw pulse circle
      final pulsePaint = Paint()
        ..color = Colors.red.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 16, pulsePaint);

      // Draw marker with gradient
      final markerGradient = RadialGradient(
        colors: [
          Colors.red[400]!,
          Colors.red[700]!,
        ],
      );
      
      final markerPaint = Paint()
        ..shader = markerGradient.createShader(
          Rect.fromCircle(center: Offset(x, y), radius: 10),
        )
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      // Draw pin shape (teardrop)
      final pinPath = Path();
      pinPath.addOval(Rect.fromCircle(center: Offset(x, y - 4), radius: 8));
      pinPath.moveTo(x, y + 4);
      pinPath.lineTo(x - 5, y - 2);
      pinPath.lineTo(x + 5, y - 2);
      pinPath.close();

      canvas.drawPath(pinPath, markerPaint);
      canvas.drawPath(pinPath, borderPaint);
      
      // Draw location number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - 8),
      );
    }
  }

  void _drawContinents(Canvas canvas, Size size) {
    // Simplified continent shapes for context
    final continentPaint = Paint()
      ..color = Colors.green[100]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final continentBorder = Paint()
      ..color = Colors.green[200]!.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // North America (simplified)
    final northAmerica = Path();
    northAmerica.moveTo(size.width * 0.15, size.height * 0.25);
    northAmerica.lineTo(size.width * 0.25, size.height * 0.2);
    northAmerica.lineTo(size.width * 0.3, size.height * 0.3);
    northAmerica.lineTo(size.width * 0.28, size.height * 0.45);
    northAmerica.lineTo(size.width * 0.2, size.height * 0.5);
    northAmerica.lineTo(size.width * 0.15, size.height * 0.4);
    northAmerica.close();
    canvas.drawPath(northAmerica, continentPaint);
    canvas.drawPath(northAmerica, continentBorder);

    // Europe/Africa (simplified)
    final europeAfrica = Path();
    europeAfrica.moveTo(size.width * 0.48, size.height * 0.25);
    europeAfrica.lineTo(size.width * 0.55, size.height * 0.22);
    europeAfrica.lineTo(size.width * 0.58, size.height * 0.35);
    europeAfrica.lineTo(size.width * 0.56, size.height * 0.55);
    europeAfrica.lineTo(size.width * 0.5, size.height * 0.65);
    europeAfrica.lineTo(size.width * 0.46, size.height * 0.5);
    europeAfrica.close();
    canvas.drawPath(europeAfrica, continentPaint);
    canvas.drawPath(europeAfrica, continentBorder);

    // Asia/Australia region (simplified)
    final asia = Path();
    asia.moveTo(size.width * 0.65, size.height * 0.2);
    asia.lineTo(size.width * 0.85, size.height * 0.25);
    asia.lineTo(size.width * 0.88, size.height * 0.4);
    asia.lineTo(size.width * 0.78, size.height * 0.55);
    asia.lineTo(size.width * 0.68, size.height * 0.45);
    asia.close();
    canvas.drawPath(asia, continentPaint);
    canvas.drawPath(asia, continentBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

