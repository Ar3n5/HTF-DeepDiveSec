import 'package:flutter/material.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart' as s;
import 'ocean_stats_card.dart';
import 'ocean_chart_widget.dart';
import 'ocean_gauge_widget.dart';
import 'ocean_map_widget.dart';
import 'ocean_interactive_map.dart';
import 'ocean_location_card.dart';
import 'ocean_heatmap_widget.dart';

/// Custom ocean visualization widgets for the GenUI catalog
class OceanCatalogItems {
  /// Create a catalog with ocean-specific widgets
  static Catalog createOceanCatalog() {
    // Start with core catalog and add custom ocean components
    return CoreCatalogItems.asCatalog().copyWith([
      oceanStatsCard,
      oceanLineChart,
      oceanGauge,
      oceanMap,
      oceanInteractiveMap,
      oceanLocationCard,
      oceanHeatmap,
    ]);
  }

  /// OceanStatsCard - Beautiful card with icon, value, and optional statistics
  static final oceanStatsCard = CatalogItem(
    name: 'OceanStatsCard',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Title of the measurement'),
        'value': s.S.string(description: 'Current value as string'),
        'unit': s.S.string(
          description: 'Unit of measurement (e.g., °C, PSU, m)',
        ),
        'subtitle': s.S.string(description: 'Additional context or location'),
        'icon': s.S.string(
          description:
              'Icon name: thermostat, waves, water_drop, place, speed, science, air',
        ),
        'color': s.S.string(
          description: 'Color: blue, orange, green, red, teal, purple, cyan',
        ),
        'min': s.S.number(description: 'Minimum value (optional)'),
        'max': s.S.number(description: 'Maximum value (optional)'),
        'avg': s.S.number(description: 'Average value (optional)'),
      },
      required: ['title', 'value'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return OceanStatsCard(
        title: data['title'] as String,
        value: data['value']?.toString() ?? '0',
        unit: data['unit'] as String? ?? '',
        subtitle: data['subtitle'] as String? ?? '',
        icon: _parseIcon(data['icon'] as String? ?? 'water_drop'),
        color: _parseColor(data['color'] as String? ?? 'blue'),
        min: data['min'] != null ? (data['min'] as num).toDouble() : null,
        max: data['max'] != null ? (data['max'] as num).toDouble() : null,
        avg: data['avg'] != null ? (data['avg'] as num).toDouble() : null,
      );
    },
  );

  /// OceanLineChart - Time series line chart with gradient fill
  static final oceanLineChart = CatalogItem(
    name: 'OceanLineChart',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Chart title'),
        'dataPoints': s.S.list(
          description: 'Array of data points with y values',
          items: s.S.object(
            properties: {
              'y': s.S.number(description: 'Value'),
              'x': s.S.string(description: 'Optional timestamp/label'),
            },
            required: ['y'],
          ),
        ),
        'unit': s.S.string(description: 'Unit of measurement'),
        'color': s.S.string(
          description: 'Color: blue, orange, green, red, teal',
        ),
      },
      required: ['title', 'dataPoints'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      final dataPoints =
          (data['dataPoints'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return OceanLineChart(
        title: data['title'] as String,
        dataPoints: dataPoints,
        unit: data['unit'] as String? ?? '',
        color: _parseColor(data['color'] as String? ?? 'blue'),
      );
    },
  );

  /// OceanGauge - Circular gauge with needle
  static final oceanGauge = CatalogItem(
    name: 'OceanGauge',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Gauge title'),
        'value': s.S.number(description: 'Current value'),
        'min': s.S.number(description: 'Minimum range value'),
        'max': s.S.number(description: 'Maximum range value'),
        'unit': s.S.string(description: 'Unit of measurement'),
        'color': s.S.string(
          description: 'Color: blue, orange, green, red, teal',
        ),
      },
      required: ['title', 'value', 'min', 'max'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return OceanGaugeWidget(
        title: data['title'] as String,
        value: (data['value'] as num).toDouble(),
        min: (data['min'] as num).toDouble(),
        max: (data['max'] as num).toDouble(),
        unit: data['unit'] as String? ?? '',
        color: _parseColor(data['color'] as String? ?? 'blue'),
      );
    },
  );

  /// OceanMap - Map widget with location markers (static)
  static final oceanMap = CatalogItem(
    name: 'OceanMap',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Map title'),
        'locations': s.S.list(
          description: 'Array of location objects',
          items: s.S.object(
            properties: {
              'name': s.S.string(description: 'Location name'),
              'latitude': s.S.number(description: 'Latitude'),
              'longitude': s.S.number(description: 'Longitude'),
              'value': s.S.string(description: 'Measurement value'),
            },
            required: ['name', 'latitude', 'longitude'],
          ),
        ),
      },
      required: ['title', 'locations'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      final locations =
          (data['locations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return OceanMapWidget(
        title: data['title'] as String,
        locations: locations,
      );
    },
  );

  /// OceanInteractiveMap - Interactive map with OpenStreetMap (zoom/pan)
  static final oceanInteractiveMap = CatalogItem(
    name: 'OceanInteractiveMap',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Map title'),
        'locations': s.S.list(
          description: 'Array of location objects',
          items: s.S.object(
            properties: {
              'name': s.S.string(description: 'Location name'),
              'latitude': s.S.number(description: 'Latitude'),
              'longitude': s.S.number(description: 'Longitude'),
              'value': s.S.string(description: 'Measurement value'),
            },
            required: ['name', 'latitude', 'longitude'],
          ),
        ),
      },
      required: ['title', 'locations'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      final locations =
          (data['locations'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return OceanInteractiveMap(
        title: data['title'] as String,
        locations: locations,
      );
    },
  );

  /// OceanLocationCard - Card showing location with rank and measurements
  static final oceanLocationCard = CatalogItem(
    name: 'OceanLocationCard',
    dataSchema: s.S.object(
      properties: {
        'name': s.S.string(description: 'Location name'),
        'latitude': s.S.number(description: 'Latitude'),
        'longitude': s.S.number(description: 'Longitude'),
        'rank': s.S.integer(
          description: 'Rank number (1=gold, 2=silver, 3=bronze)',
        ),
        'measurements': s.S.object(
          description: 'Map of measurement names to values',
        ),
      },
      required: ['name', 'latitude', 'longitude'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      return OceanLocationCard(
        name: data['name'] as String,
        latitude: (data['latitude'] as num).toDouble(),
        longitude: (data['longitude'] as num).toDouble(),
        rank: data['rank'] as int? ?? 0,
        measurements: data['measurements'] as Map<String, dynamic>?,
      );
    },
  );

  /// OceanHeatmap - Heatmap visualization for regional temperature/salinity
  static final oceanHeatmap = CatalogItem(
    name: 'OceanHeatmap',
    dataSchema: s.S.object(
      properties: {
        'title': s.S.string(description: 'Heatmap title'),
        'unit': s.S.string(description: 'Unit of measurement'),
        'data': s.S.list(
          description: 'Array of region data points',
          items: s.S.object(
            properties: {
              'region': s.S.string(description: 'Region name'),
              'value': s.S.number(description: 'Measurement value'),
            },
            required: ['region', 'value'],
          ),
        ),
      },
      required: ['title', 'data'],
    ),
    widgetBuilder: (itemContext) {
      final data = itemContext.data as JsonMap;
      final dataPoints =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      return OceanHeatmap(
        title: data['title'] as String,
        data: dataPoints,
        unit: data['unit'] as String? ?? '',
      );
    },
  );

  // Helper methods for parsing
  static IconData _parseIcon(String name) {
    const icons = {
      'thermostat': IconData(0xe3a6, fontFamily: 'MaterialIcons'),
      'waves': IconData(0xf05b8, fontFamily: 'MaterialIcons'),
      'water_drop': IconData(0xe798, fontFamily: 'MaterialIcons'),
      'place': IconData(0xe55f, fontFamily: 'MaterialIcons'),
      'speed': IconData(0xe55e, fontFamily: 'MaterialIcons'),
      'science': IconData(0xea4b, fontFamily: 'MaterialIcons'),
      'air': IconData(0xe40c, fontFamily: 'MaterialIcons'),
    };
    return icons[name.toLowerCase()] ?? icons['water_drop']!;
  }

  static Color _parseColor(String colorName) {
    const colors = {
      'blue': Color(0xFF2196F3),
      'orange': Color(0xFFFF9800),
      'green': Color(0xFF4CAF50),
      'red': Color(0xFFF44336),
      'teal': Color(0xFF009688),
      'purple': Color(0xFF9C27B0),
      'cyan': Color(0xFF00BCD4),
    };
    return colors[colorName.toLowerCase()] ?? colors['blue']!;
  }
}
