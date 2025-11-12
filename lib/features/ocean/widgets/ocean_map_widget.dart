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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.blue[200]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // Real world map from Wikimedia Commons
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/8/83/Equirectangular_projection_SW.jpg',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to custom painted map if image fails to load
                        return CustomPaint(
                          painter: _MapPainter(locations: locations),
                          child: Container(),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                'Loading world map...',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Overlay location markers
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LocationMarkerPainter(locations: locations),
                      ),
                    ),
                  ],
                ),
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

class _LocationMarkerPainter extends CustomPainter {
  final List<Map<String, dynamic>> locations;

  _LocationMarkerPainter({required this.locations});

  @override
  void paint(Canvas canvas, Size size) {
    // Only draw location markers on top of the real map image
    _drawLocationMarkers(canvas, size);
  }

  void _drawLocationMarkers(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Fallback map painter if the image doesn't load
class _MapPainter extends CustomPainter {
  final List<Map<String, dynamic>> locations;

  _MapPainter({required this.locations});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple blue ocean background as fallback
    final oceanPaint = Paint()
      ..color = Colors.blue[200]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), oceanPaint);

    // Draw loading text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Loading map...',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2, size.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

