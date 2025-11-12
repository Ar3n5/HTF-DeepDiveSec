import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/ocean_data.dart';
import 'mock_ocean_data_service.dart';

/// Service for fetching ocean data via MCP (Model Context Protocol)
/// Falls back to mock data if MCP is unavailable
class OceanMcpService {
  final Logger _logger = Logger('OceanMcpService');
  final MockOceanDataService _mockService = MockOceanDataService();
  
  // MCP endpoint configuration
  final String? mcpEndpoint;
  final Duration timeout;
  
  bool _mcpAvailable = false;
  
  OceanMcpService({
    this.mcpEndpoint,
    this.timeout = const Duration(seconds: 10),
  });

  /// Check if MCP service is available
  Future<bool> checkMcpAvailability() async {
    if (mcpEndpoint == null || mcpEndpoint!.isEmpty) {
      _logger.info('MCP endpoint not configured, using mock data');
      return false;
    }

    try {
      final response = await http
          .get(Uri.parse('$mcpEndpoint/health'))
          .timeout(timeout);
      _mcpAvailable = response.statusCode == 200;
      _logger.info('MCP service available: $_mcpAvailable');
      return _mcpAvailable;
    } catch (e) {
      _logger.warning('MCP service unavailable: $e');
      _mcpAvailable = false;
      return false;
    }
  }

  /// Fetch ocean time series data
  Future<OceanTimeSeries> fetchTimeSeries({
    required String measurementType,
    required String region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Try MCP first if available
    if (_mcpAvailable && mcpEndpoint != null) {
      try {
        final response = await http.post(
          Uri.parse('$mcpEndpoint/ocean/timeseries'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'measurementType': measurementType,
            'region': region,
            'startDate': startDate?.toIso8601String(),
            'endDate': endDate?.toIso8601String(),
          }),
        ).timeout(timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _logger.info('Fetched time series from MCP for $measurementType in $region');
          return OceanTimeSeries.fromJson(data);
        }
      } catch (e) {
        _logger.warning('Failed to fetch from MCP, using mock data: $e');
      }
    }

    // Fall back to mock data
    _logger.info('Using mock data for $measurementType in $region');
    final daysBack = startDate != null
        ? DateTime.now().difference(startDate).inDays
        : 30;
    return _mockService.generateTimeSeries(
      measurementType: measurementType,
      region: region,
      daysBack: daysBack.clamp(1, 365),
    );
  }

  /// Fetch location data
  Future<OceanLocation> fetchLocationData({
    required double latitude,
    required double longitude,
    String? name,
  }) async {
    // Try MCP first if available
    if (_mcpAvailable && mcpEndpoint != null) {
      try {
        final response = await http.post(
          Uri.parse('$mcpEndpoint/ocean/location'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'latitude': latitude,
            'longitude': longitude,
            'name': name,
          }),
        ).timeout(timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _logger.info('Fetched location data from MCP for ($latitude, $longitude)');
          return OceanLocation.fromJson(data);
        }
      } catch (e) {
        _logger.warning('Failed to fetch from MCP, using mock data: $e');
      }
    }

    // Fall back to mock data
    _logger.info('Using mock location data for ($latitude, $longitude)');
    return _mockService.generateLocationData(
      latitude: latitude,
      longitude: longitude,
      name: name,
    );
  }

  /// Get top locations for a measurement
  Future<List<OceanLocation>> fetchTopLocations({
    required String measurementType,
    int count = 5,
  }) async {
    // Try MCP first if available
    if (_mcpAvailable && mcpEndpoint != null) {
      try {
        final response = await http.post(
          Uri.parse('$mcpEndpoint/ocean/top-locations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'measurementType': measurementType,
            'count': count,
          }),
        ).timeout(timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as List;
          _logger.info('Fetched top locations from MCP for $measurementType');
          return data.map((e) => OceanLocation.fromJson(e)).toList();
        }
      } catch (e) {
        _logger.warning('Failed to fetch from MCP, using mock data: $e');
      }
    }

    // Fall back to mock data
    _logger.info('Using mock top locations for $measurementType');
    return _mockService.getTopLocations(
      measurementType: measurementType,
      count: count,
    );
  }

  /// Get regional summary
  Future<Map<String, dynamic>> fetchRegionalSummary(String region) async {
    // Try MCP first if available
    if (_mcpAvailable && mcpEndpoint != null) {
      try {
        final response = await http.get(
          Uri.parse('$mcpEndpoint/ocean/summary/$region'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(timeout);

        if (response.statusCode == 200) {
          _logger.info('Fetched regional summary from MCP for $region');
          return jsonDecode(response.body);
        }
      } catch (e) {
        _logger.warning('Failed to fetch from MCP, using mock data: $e');
      }
    }

    // Fall back to mock data
    _logger.info('Using mock regional summary for $region');
    return _mockService.getRegionalSummary(region);
  }
}

