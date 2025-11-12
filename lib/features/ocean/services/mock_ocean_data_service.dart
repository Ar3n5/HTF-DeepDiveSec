import 'dart:math';
import '../models/ocean_data.dart';

/// Mock ocean data service for fallback when MCP is unavailable
class MockOceanDataService {
  final Random _random = Random();

  /// Generate mock ocean time series data
  OceanTimeSeries generateTimeSeries({
    required String measurementType,
    required String region,
    int daysBack = 30,
    int pointsPerDay = 4,
  }) {
    final now = DateTime.now();
    final dataPoints = <OceanDataPoint>[];

    // Base values for different measurement types
    final baseValues = {
      'temperature': 15.0,
      'salinity': 35.0,
      'waveHeight': 2.0,
      'currentSpeed': 0.5,
      'pressure': 1013.0,
      'oxygen': 8.0,
      'chlorophyll': 2.5,
      'ph': 8.1,
    };

    // Variation ranges
    final variations = {
      'temperature': 5.0,
      'salinity': 2.0,
      'waveHeight': 1.5,
      'currentSpeed': 0.3,
      'pressure': 15.0,
      'oxygen': 2.0,
      'chlorophyll': 1.0,
      'ph': 0.3,
    };

    final base = baseValues[measurementType.toLowerCase()] ?? 10.0;
    final variation = variations[measurementType.toLowerCase()] ?? 2.0;

    for (var i = 0; i < daysBack * pointsPerDay; i++) {
      final timestamp = now.subtract(Duration(
        hours: (daysBack * 24 * (1 - i / (daysBack * pointsPerDay))).round(),
      ));

      // Create trending data with some randomness
      final trendFactor = i / (daysBack * pointsPerDay);
      final randomFactor = (_random.nextDouble() - 0.5) * 2;
      final value = base + (variation * trendFactor * 0.5) + (randomFactor * variation * 0.3);

      dataPoints.add(OceanDataPoint(
        timestamp: timestamp,
        value: value,
        unit: _getUnit(measurementType),
        metadata: {
          'source': 'mock',
          'region': region,
        },
      ));
    }

    return OceanTimeSeries(
      measurementType: measurementType,
      region: region,
      dataPoints: dataPoints,
      description: 'Mock data for $measurementType in $region',
    );
  }

  /// Generate mock location data with current measurements
  OceanLocation generateLocationData({
    required double latitude,
    required double longitude,
    String? name,
  }) {
    return OceanLocation(
      latitude: latitude,
      longitude: longitude,
      name: name,
      currentMeasurements: {
        'temperature': 15.0 + (_random.nextDouble() - 0.5) * 10,
        'salinity': 35.0 + (_random.nextDouble() - 0.5) * 4,
        'waveHeight': 1.0 + _random.nextDouble() * 3,
        'currentSpeed': 0.2 + _random.nextDouble() * 0.8,
      },
    );
  }

  /// Get locations with highest measurements
  List<OceanLocation> getTopLocations({
    required String measurementType,
    int count = 5,
  }) {
    final locations = [
      {'name': 'North Atlantic', 'lat': 45.0, 'lon': -30.0},
      {'name': 'Pacific Northwest', 'lat': 48.0, 'lon': -125.0},
      {'name': 'Southern Ocean', 'lat': -55.0, 'lon': 0.0},
      {'name': 'North Sea', 'lat': 55.0, 'lon': 4.0},
      {'name': 'Mediterranean Sea', 'lat': 38.0, 'lon': 15.0},
      {'name': 'Caribbean Sea', 'lat': 15.0, 'lon': -75.0},
      {'name': 'Arctic Ocean', 'lat': 80.0, 'lon': 0.0},
      {'name': 'Gulf of Mexico', 'lat': 25.0, 'lon': -90.0},
    ];

    final result = <OceanLocation>[];
    for (var i = 0; i < count && i < locations.length; i++) {
      final loc = locations[i];
      result.add(generateLocationData(
        latitude: loc['lat'] as double,
        longitude: loc['lon'] as double,
        name: loc['name'] as String,
      ));
    }

    // Sort by the requested measurement type
    result.sort((a, b) {
      final aVal = a.currentMeasurements?[measurementType.toLowerCase()] ?? 0.0;
      final bVal = b.currentMeasurements?[measurementType.toLowerCase()] ?? 0.0;
      return bVal.compareTo(aVal);
    });

    return result.take(count).toList();
  }

  /// Get regional summary statistics
  Map<String, dynamic> getRegionalSummary(String region) {
    return {
      'region': region,
      'temperature': {
        'current': 15.0 + (_random.nextDouble() - 0.5) * 10,
        'min': 10.0 + (_random.nextDouble() * 5),
        'max': 20.0 + (_random.nextDouble() * 5),
        'avg': 15.0 + (_random.nextDouble() - 0.5) * 5,
        'unit': '°C',
      },
      'salinity': {
        'current': 35.0 + (_random.nextDouble() - 0.5) * 4,
        'min': 33.0 + (_random.nextDouble() * 2),
        'max': 37.0 + (_random.nextDouble() * 2),
        'avg': 35.0 + (_random.nextDouble() - 0.5) * 2,
        'unit': 'PSU',
      },
      'waveHeight': {
        'current': 2.0 + (_random.nextDouble() * 2),
        'min': 0.5 + (_random.nextDouble()),
        'max': 4.0 + (_random.nextDouble() * 2),
        'avg': 2.0 + (_random.nextDouble()),
        'unit': 'm',
      },
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  String _getUnit(String measurementType) {
    final units = {
      'temperature': '°C',
      'salinity': 'PSU',
      'waveHeight': 'm',
      'waveheight': 'm',
      'currentSpeed': 'm/s',
      'currentspeed': 'm/s',
      'pressure': 'dbar',
      'oxygen': 'mg/L',
      'chlorophyll': 'mg/m³',
      'ph': '',
    };
    return units[measurementType.toLowerCase()] ?? '';
  }
}

