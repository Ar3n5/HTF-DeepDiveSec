import 'package:flutter/material.dart';

/// Realistic map widget using actual world map image
class OceanMapWithImage extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final String title;

  const OceanMapWithImage({
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[800],
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
                    // Use a world map image as background
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/8/83/Equirectangular_projection_SW.jpg',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to custom painted map if image fails
                        return CustomPaint(
                          painter: _FallbackMapPainter(locations: locations),
                          child: Container(),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                    // Overlay location markers on top of the map
                    ...locations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final location = entry.value;
                      final lat = (location['latitude'] ?? location['lat'] ?? 0.0) as num;
                      final lon = (location['longitude'] ?? location['lon'] ?? 0.0) as num;

                      // Convert lat/lon to x/y position
                      final xPercent = (lon.toDouble() + 180) / 360;
                      final yPercent = (90 - lat.toDouble()) / 180;

                      return Positioned(
                        left: xPercent * MediaQuery.of(context).size.width - 20,
                        top: yPercent * 300 - 35,
                        child: _LocationMarker(number: index + 1),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...locations.map((loc) => _buildLocationInfo(loc, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> location, BuildContext context) {
    final name = location['name'] ?? 'Unknown';
    final lat = location['latitude'] ?? location['lat'] ?? 0.0;
    final lon = location['longitude'] ?? location['lon'] ?? 0.0;
    final value = location['value'];
    final index = locations.indexOf(location) + 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
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
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          if (value != null)
            Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final int number;

  const _LocationMarker({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _FallbackMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> locations;

  _FallbackMapPainter({required this.locations});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple fallback - blue background with text
    final paint = Paint()..color = Colors.blue[200]!;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Map loading...',
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

