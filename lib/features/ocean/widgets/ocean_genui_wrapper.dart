import 'package:flutter/material.dart';
import 'ocean_chart_widget.dart';
import 'ocean_gauge_widget.dart';
import 'ocean_map_widget.dart';
import 'ocean_stats_card.dart';
import 'ocean_location_card.dart';

/// Wrapper to easily create ocean visualization widgets from map data
class OceanGenUiWrapper {
  /// Create a line chart from data map
  static Widget createLineChart(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? 'Chart';
    final dataPoints = data['dataPoints'] as List? ?? [];
    final unit = data['unit'] as String? ?? '';
    final colorStr = data['color'] as String? ?? 'blue';
    
    final color = _parseColor(colorStr);
    
    return OceanLineChart(
      title: title,
      dataPoints: dataPoints.map((e) => e as Map<String, dynamic>).toList(),
      unit: unit,
      color: color,
    );
  }

  /// Create a gauge from data map
  static Widget createGauge(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? 'Gauge';
    final value = _parseDouble(data['value']);
    final min = _parseDouble(data['min'] ?? 0);
    final max = _parseDouble(data['max'] ?? 100);
    final unit = data['unit'] as String? ?? '';
    final colorStr = data['color'] as String? ?? 'blue';
    
    final color = _parseColor(colorStr);
    
    return OceanGaugeWidget(
      title: title,
      value: value,
      min: min,
      max: max,
      unit: unit,
      color: color,
    );
  }

  /// Create a stats card from data map
  static Widget createStatsCard(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? '';
    final value = data['value']?.toString() ?? '0';
    final unit = data['unit'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? '';
    final iconStr = data['icon'] as String? ?? 'water_drop';
    final colorStr = data['color'] as String? ?? 'blue';
    final min = data['min'] != null ? _parseDouble(data['min']) : null;
    final max = data['max'] != null ? _parseDouble(data['max']) : null;
    final avg = data['avg'] != null ? _parseDouble(data['avg']) : null;
    
    final icon = _parseIcon(iconStr);
    final color = _parseColor(colorStr);
    
    return OceanStatsCard(
      title: title,
      value: value,
      unit: unit,
      subtitle: subtitle,
      icon: icon,
      color: color,
      min: min,
      max: max,
      avg: avg,
    );
  }

  /// Create a location card from data map
  static Widget createLocationCard(Map<String, dynamic> data) {
    final name = data['name'] as String? ?? 'Unknown';
    final latitude = _parseDouble(data['latitude'] ?? data['lat'] ?? 0);
    final longitude = _parseDouble(data['longitude'] ?? data['lon'] ?? 0);
    final rank = data['rank'] as int? ?? 0;
    final measurements = data['measurements'] as Map<String, dynamic>?;
    
    return OceanLocationCard(
      name: name,
      latitude: latitude,
      longitude: longitude,
      rank: rank,
      measurements: measurements,
    );
  }

  /// Create a map widget from data map
  static Widget createMap(Map<String, dynamic> data) {
    final title = data['title'] as String? ?? 'Map';
    final locations = data['locations'] as List? ?? [];
    
    return OceanMapWidget(
      title: title,
      locations: locations.map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Color _parseColor(String colorStr) {
    final colors = {
      'blue': Colors.blue,
      'orange': Colors.orange,
      'green': Colors.green,
      'red': Colors.red,
      'teal': Colors.teal,
      'purple': Colors.purple,
      'cyan': Colors.cyan,
    };
    return colors[colorStr.toLowerCase()] ?? Colors.blue;
  }

  static IconData _parseIcon(String iconStr) {
    final icons = {
      'water_drop': Icons.water_drop,
      'thermostat': Icons.thermostat,
      'waves': Icons.waves,
      'place': Icons.place,
      'speed': Icons.speed,
      'science': Icons.science,
      'air': Icons.air,
    };
    return icons[iconStr.toLowerCase()] ?? Icons.water_drop;
  }
}

