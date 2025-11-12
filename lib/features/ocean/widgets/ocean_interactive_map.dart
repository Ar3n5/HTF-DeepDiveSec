import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Interactive map widget using flutter_map with OpenStreetMap tiles
class OceanInteractiveMap extends StatefulWidget {
  final List<Map<String, dynamic>> locations;
  final String title;

  const OceanInteractiveMap({
    super.key,
    required this.locations,
    this.title = 'Ocean Locations',
  });

  @override
  State<OceanInteractiveMap> createState() => _OceanInteractiveMapState();
}

class _OceanInteractiveMapState extends State<OceanInteractiveMap> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate bounds for all locations
    LatLng center = const LatLng(20, 0); // Default center
    if (widget.locations.isNotEmpty) {
      double sumLat = 0;
      double sumLon = 0;
      for (final loc in widget.locations) {
        sumLat += (loc['latitude'] ?? loc['lat'] ?? 0.0) as num;
        sumLon += (loc['longitude'] ?? loc['lon'] ?? 0.0) as num;
      }
      center = LatLng(
        sumLat / widget.locations.length,
        sumLon / widget.locations.length,
      );
    }

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
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '🖱️ Click and drag to pan • Scroll to zoom',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.blue[200]!,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 2.0,
                    minZoom: 1.0,
                    maxZoom: 8.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractFlags.all,
                    ),
                  ),
                  children: [
                    // Map tiles layer
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hackthefuture.oceanexplorer',
                      tileBuilder: isDark ? _darkModeTileBuilder : null,
                    ),
                    // Markers layer
                    MarkerLayer(
                      markers: widget.locations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final location = entry.value;
                        final lat = (location['latitude'] ?? location['lat'] ?? 0.0) as num;
                        final lon = (location['longitude'] ?? location['lon'] ?? 0.0) as num;
                        final name = location['name'] ?? 'Location ${index + 1}';

                        return Marker(
                          point: LatLng(lat.toDouble(), lon.toDouble()),
                          width: 50,
                          height: 50,
                          child: _LocationMarker(
                            number: index + 1,
                            name: name,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...widget.locations.map((loc) => _buildLocationInfo(loc)),
          ],
        ),
      ),
    );
  }

  Widget? _darkModeTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.2126, -0.7152, -0.0722, 0, 255, // Red channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Green channel
        -0.2126, -0.7152, -0.0722, 0, 255, // Blue channel
        0, 0, 0, 1, 0, // Alpha channel
      ]),
      child: tileWidget,
    );
  }

  Widget _buildLocationInfo(Map<String, dynamic> location) {
    final name = location['name'] ?? 'Unknown';
    final lat = location['latitude'] ?? location['lat'] ?? 0.0;
    final lon = location['longitude'] ?? location['lon'] ?? 0.0;
    final value = location['value'];
    final index = widget.locations.indexOf(location) + 1;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
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
                  fontSize: 14,
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
  final String name;

  const _LocationMarker({
    required this.number,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

