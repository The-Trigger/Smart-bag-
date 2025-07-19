import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorWidget extends StatelessWidget {
  final double batteryLevel;
  final double temperature;
  final double rainLevel;

  const SensorWidget({
    super.key,
    required this.batteryLevel,
    required this.temperature,
    required this.rainLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Data',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Battery Level
        _buildSensorCard(
          context,
          title: 'Battery Level',
          value: '${batteryLevel.toStringAsFixed(1)}%',
          icon: Icons.battery_full,
          color: _getBatteryColor(batteryLevel),
          progress: batteryLevel / 100,
          unit: '%',
        ),
        
        const SizedBox(height: 12),
        
        // Temperature
        _buildSensorCard(
          context,
          title: 'Temperature',
          value: '${temperature.toStringAsFixed(1)}°C',
          icon: Icons.thermostat,
          color: _getTemperatureColor(temperature),
          progress: (temperature + 20) / 60, // Normalize -20 to 40°C
          unit: '°C',
        ),
        
        const SizedBox(height: 12),
        
        // Rain Level
        _buildSensorCard(
          context,
          title: 'Rain Level',
          value: '${rainLevel.toStringAsFixed(1)}%',
          icon: Icons.water_drop,
          color: _getRainColor(rainLevel),
          progress: rainLevel / 100,
          unit: '%',
        ),
      ],
    );
  }

  Widget _buildSensorCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double progress,
    required String unit,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
            
            const SizedBox(height: 8),
            
            // Status Text
            Text(
              _getStatusText(title, progress),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatteryColor(double level) {
    if (level >= 70) return Colors.green;
    if (level >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getTemperatureColor(double temp) {
    if (temp >= 30) return Colors.red;
    if (temp >= 20) return Colors.orange;
    if (temp >= 10) return Colors.yellow.shade700;
    return Colors.blue;
  }

  Color _getRainColor(double level) {
    if (level >= 70) return Colors.blue;
    if (level >= 30) return Colors.lightBlue;
    return Colors.grey;
  }

  String _getStatusText(String title, double progress) {
    switch (title) {
      case 'Battery Level':
        if (progress >= 0.7) return 'Good battery level';
        if (progress >= 0.3) return 'Battery level moderate';
        return 'Low battery - consider charging';
      case 'Temperature':
        if (progress >= 0.8) return 'High temperature detected';
        if (progress >= 0.6) return 'Warm temperature';
        if (progress >= 0.4) return 'Normal temperature';
        return 'Cool temperature';
      case 'Rain Level':
        if (progress >= 0.7) return 'Heavy rain detected';
        if (progress >= 0.3) return 'Light rain detected';
        return 'No rain detected';
      default:
        return '';
    }
  }
}