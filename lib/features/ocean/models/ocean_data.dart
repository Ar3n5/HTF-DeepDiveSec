/// Ocean data models for the Agentic Ocean Explorer app
class OceanDataPoint {
  final DateTime timestamp;
  final double value;
  final String? unit;
  final Map<String, dynamic>? metadata;

  const OceanDataPoint({
    required this.timestamp,
    required this.value,
    this.unit,
    this.metadata,
  });

  factory OceanDataPoint.fromJson(Map<String, dynamic> json) {
    return OceanDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      if (unit != null) 'unit': unit,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class OceanTimeSeries {
  final String measurementType;
  final String region;
  final List<OceanDataPoint> dataPoints;
  final String? description;

  const OceanTimeSeries({
    required this.measurementType,
    required this.region,
    required this.dataPoints,
    this.description,
  });

  factory OceanTimeSeries.fromJson(Map<String, dynamic> json) {
    return OceanTimeSeries(
      measurementType: json['measurementType'] as String,
      region: json['region'] as String,
      dataPoints: (json['dataPoints'] as List<dynamic>)
          .map((e) => OceanDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurementType': measurementType,
      'region': region,
      'dataPoints': dataPoints.map((e) => e.toJson()).toList(),
      if (description != null) 'description': description,
    };
  }

  double get minValue =>
      dataPoints.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  double get maxValue =>
      dataPoints.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  double get avgValue =>
      dataPoints.map((e) => e.value).reduce((a, b) => a + b) /
      dataPoints.length;
}

class OceanLocation {
  final double latitude;
  final double longitude;
  final String? name;
  final Map<String, double>? currentMeasurements;

  const OceanLocation({
    required this.latitude,
    required this.longitude,
    this.name,
    this.currentMeasurements,
  });

  factory OceanLocation.fromJson(Map<String, dynamic> json) {
    return OceanLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
      currentMeasurements: json['currentMeasurements'] != null
          ? Map<String, double>.from(json['currentMeasurements'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (name != null) 'name': name,
      if (currentMeasurements != null)
        'currentMeasurements': currentMeasurements,
    };
  }
}

enum OceanMeasurementType {
  temperature,
  salinity,
  waveHeight,
  currentSpeed,
  pressure,
  oxygen,
  chlorophyll,
  ph;

  String get displayName {
    switch (this) {
      case OceanMeasurementType.temperature:
        return 'Temperature';
      case OceanMeasurementType.salinity:
        return 'Salinity';
      case OceanMeasurementType.waveHeight:
        return 'Wave Height';
      case OceanMeasurementType.currentSpeed:
        return 'Current Speed';
      case OceanMeasurementType.pressure:
        return 'Pressure';
      case OceanMeasurementType.oxygen:
        return 'Dissolved Oxygen';
      case OceanMeasurementType.chlorophyll:
        return 'Chlorophyll';
      case OceanMeasurementType.ph:
        return 'pH Level';
    }
  }

  String get defaultUnit {
    switch (this) {
      case OceanMeasurementType.temperature:
        return '°C';
      case OceanMeasurementType.salinity:
        return 'PSU';
      case OceanMeasurementType.waveHeight:
        return 'm';
      case OceanMeasurementType.currentSpeed:
        return 'm/s';
      case OceanMeasurementType.pressure:
        return 'dbar';
      case OceanMeasurementType.oxygen:
        return 'mg/L';
      case OceanMeasurementType.chlorophyll:
        return 'mg/m³';
      case OceanMeasurementType.ph:
        return '';
    }
  }
}

