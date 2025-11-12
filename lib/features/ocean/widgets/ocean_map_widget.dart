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
    final index = locations.indexOf(location) + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Show the location number
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$name (${lat.toStringAsFixed(1)}°, ${lon.toStringAsFixed(1)}°)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (value != null)
            Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
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

      // Draw larger pin with better visibility
      final pinSize = 12.0;
      
      // Draw pin shape (teardrop) - larger
      final pinPath = Path();
      pinPath.addOval(Rect.fromCircle(center: Offset(x, y - 6), radius: pinSize));
      pinPath.moveTo(x, y + 6);
      pinPath.lineTo(x - 8, y - 4);
      pinPath.lineTo(x + 8, y - 4);
      pinPath.close();

      canvas.drawPath(pinPath, markerPaint);
      canvas.drawPath(pinPath, borderPaint);
      
      // Draw white circle background for number
      final numberCirclePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y - 6), 9, numberCirclePaint);
      
      // Draw location number - larger and more visible
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - 14),
      );
    }
  }

  void _drawContinents(Canvas canvas, Size size) {
    // More realistic continent shapes
    final continentPaint = Paint()
      ..color = const Color(0xFF8BC34A).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final continentBorder = Paint()
      ..color = const Color(0xFF689F38).withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // North America (more detailed)
    final northAmerica = Path();
    northAmerica.moveTo(size.width * 0.12, size.height * 0.15); // Alaska
    northAmerica.lineTo(size.width * 0.18, size.height * 0.12);
    northAmerica.lineTo(size.width * 0.22, size.height * 0.18); // Canada
    northAmerica.lineTo(size.width * 0.28, size.height * 0.22);
    northAmerica.lineTo(size.width * 0.26, size.height * 0.32); // US East Coast
    northAmerica.lineTo(size.width * 0.22, size.height * 0.38); // Florida
    northAmerica.lineTo(size.width * 0.20, size.height * 0.45); // Mexico
    northAmerica.lineTo(size.width * 0.18, size.height * 0.48); // Central America
    northAmerica.lineTo(size.width * 0.15, size.height * 0.42); // West Coast
    northAmerica.lineTo(size.width * 0.10, size.height * 0.30);
    northAmerica.lineTo(size.width * 0.12, size.height * 0.20);
    northAmerica.close();
    canvas.drawPath(northAmerica, continentPaint);
    canvas.drawPath(northAmerica, continentBorder);

    // South America
    final southAmerica = Path();
    southAmerica.moveTo(size.width * 0.22, size.height * 0.52);
    southAmerica.lineTo(size.width * 0.26, size.height * 0.50);
    southAmerica.lineTo(size.width * 0.28, size.height * 0.58);
    southAmerica.lineTo(size.width * 0.27, size.height * 0.70);
    southAmerica.lineTo(size.width * 0.24, size.height * 0.78);
    southAmerica.lineTo(size.width * 0.22, size.height * 0.75);
    southAmerica.lineTo(size.width * 0.20, size.height * 0.65);
    southAmerica.close();
    canvas.drawPath(southAmerica, continentPaint);
    canvas.drawPath(southAmerica, continentBorder);

    // Europe
    final europe = Path();
    europe.moveTo(size.width * 0.48, size.height * 0.20);
    europe.lineTo(size.width * 0.52, size.height * 0.18);
    europe.lineTo(size.width * 0.55, size.height * 0.22);
    europe.lineTo(size.width * 0.54, size.height * 0.28);
    europe.lineTo(size.width * 0.50, size.height * 0.30);
    europe.lineTo(size.width * 0.47, size.height * 0.26);
    europe.close();
    canvas.drawPath(europe, continentPaint);
    canvas.drawPath(europe, continentBorder);

    // Africa
    final africa = Path();
    africa.moveTo(size.width * 0.50, size.height * 0.32);
    africa.lineTo(size.width * 0.54, size.height * 0.30);
    africa.lineTo(size.width * 0.58, size.height * 0.35);
    africa.lineTo(size.width * 0.58, size.height * 0.45);
    africa.lineTo(size.width * 0.56, size.height * 0.58);
    africa.lineTo(size.width * 0.52, size.height * 0.68);
    africa.lineTo(size.width * 0.48, size.height * 0.65);
    africa.lineTo(size.width * 0.47, size.height * 0.52);
    africa.lineTo(size.width * 0.48, size.height * 0.40);
    africa.close();
    canvas.drawPath(africa, continentPaint);
    canvas.drawPath(africa, continentBorder);

    // Asia
    final asia = Path();
    asia.moveTo(size.width * 0.58, size.height * 0.18);
    asia.lineTo(size.width * 0.75, size.height * 0.15);
    asia.lineTo(size.width * 0.82, size.height * 0.20);
    asia.lineTo(size.width * 0.85, size.height * 0.30);
    asia.lineTo(size.width * 0.82, size.height * 0.40);
    asia.lineTo(size.width * 0.75, size.height * 0.42);
    asia.lineTo(size.width * 0.68, size.height * 0.38);
    asia.lineTo(size.width * 0.62, size.height * 0.32);
    asia.lineTo(size.width * 0.58, size.height * 0.25);
    asia.close();
    canvas.drawPath(asia, continentPaint);
    canvas.drawPath(asia, continentBorder);

    // Australia
    final australia = Path();
    australia.moveTo(size.width * 0.78, size.height * 0.58);
    australia.lineTo(size.width * 0.85, size.height * 0.56);
    australia.lineTo(size.width * 0.88, size.height * 0.62);
    australia.lineTo(size.width * 0.86, size.height * 0.68);
    australia.lineTo(size.width * 0.80, size.height * 0.68);
    australia.lineTo(size.width * 0.76, size.height * 0.64);
    australia.close();
    canvas.drawPath(australia, continentPaint);
    canvas.drawPath(australia, continentBorder);

    // Antarctica (bottom)
    final antarctica = Path();
    antarctica.moveTo(size.width * 0.0, size.height * 0.88);
    antarctica.lineTo(size.width * 1.0, size.height * 0.88);
    antarctica.lineTo(size.width * 1.0, size.height * 0.95);
    antarctica.lineTo(size.width * 0.0, size.height * 0.95);
    antarctica.close();
    canvas.drawPath(antarctica, continentPaint);
    canvas.drawPath(antarctica, continentBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

