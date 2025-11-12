import 'package:flutter/material.dart';
import 'ocean_chart_widget.dart';
import 'ocean_gauge_widget.dart';
import 'ocean_map_widget.dart';
import 'ocean_stats_card.dart';
import 'ocean_location_card.dart';

/// Demo screen showcasing all ocean visualization components
class OceanComponentsDemo extends StatelessWidget {
  const OceanComponentsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ocean Visualization Components'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📊 Statistics Cards'),
            const SizedBox(height: 12),
            OceanStatsCard(
              title: 'Ocean Temperature',
              value: '15.2',
              unit: '°C',
              subtitle: 'North Sea - Last 30 days',
              icon: Icons.thermostat,
              color: Colors.orange,
              min: 13.5,
              max: 16.8,
              avg: 15.1,
            ),
            const SizedBox(height: 12),
            OceanStatsCard(
              title: 'Wave Height',
              value: '2.5',
              unit: 'm',
              subtitle: 'Pacific Ocean - Current',
              icon: Icons.waves,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('📍 Location Cards'),
            const SizedBox(height: 12),
            OceanLocationCard(
              name: 'North Atlantic',
              latitude: 45.0,
              longitude: -30.0,
              rank: 1,
              measurements: {
                'Temp': '18.5°C',
                'Waves': '3.2m',
              },
            ),
            OceanLocationCard(
              name: 'Pacific Northwest',
              latitude: 48.0,
              longitude: -125.0,
              rank: 2,
              measurements: {
                'Temp': '12.1°C',
                'Waves': '2.8m',
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('📈 Line Chart'),
            const SizedBox(height: 12),
            OceanLineChart(
              title: 'Temperature Trend - Last 7 Days',
              unit: '°C',
              color: Colors.orange,
              dataPoints: _generateMockData(),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('📊 Bar Chart'),
            const SizedBox(height: 12),
            OceanBarChart(
              title: 'Average Temperature by Ocean',
              unit: '°C',
              data: {
                'Atlantic': 20.5,
                'Pacific': 18.2,
                'Indian': 24.8,
                'Arctic': 2.1,
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('🎯 Gauge'),
            const SizedBox(height: 12),
            OceanGaugeWidget(
              title: 'Salinity Level',
              value: 35.5,
              min: 30,
              max: 40,
              unit: 'PSU',
              color: Colors.teal,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('🗺️ Map'),
            const SizedBox(height: 12),
            OceanMapWidget(
              title: 'Measurement Locations',
              locations: [
                {'name': 'North Sea', 'latitude': 55.0, 'longitude': 4.0, 'value': '15°C'},
                {'name': 'Atlantic', 'latitude': 45.0, 'longitude': -30.0, 'value': '18°C'},
                {'name': 'Pacific', 'latitude': 30.0, 'longitude': -150.0, 'value': '22°C'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockData() {
    return [
      {'x': '2024-01-01', 'y': 14.5},
      {'x': '2024-01-02', 'y': 15.2},
      {'x': '2024-01-03', 'y': 14.8},
      {'x': '2024-01-04', 'y': 15.5},
      {'x': '2024-01-05', 'y': 16.0},
      {'x': '2024-01-06', 'y': 15.8},
      {'x': '2024-01-07', 'y': 16.2},
    ];
  }
}

