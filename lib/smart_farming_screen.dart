// lib/screens/smart_farming_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';

class SmartFarmingScreen extends StatelessWidget {
  const SmartFarmingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BilingualText(
          englishText: "Smart Farming",
          urduText: "سمارٹ فارمنگ",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonitoringCard(
              context,
              title: "Water",
              urduTitle: "پانی کا استعمال",
              value: 0.75, // 75%
              icon: Icons.water_drop_rounded,
              color: Colors.blue.shade600,
            ),
            _buildMonitoringCard(
              context,
              title: "Soil Health",
              urduTitle: "مٹی کی صحت",
              value: 0.45, // 45%
              icon: Icons.grass_rounded,
              color: AppColors.chocolateBrown,
            ),
            _buildMonitoringCard(
              context,
              title: "Fertilizer",
              urduTitle: "کھاد کا استعمال",
              value: 0.90, // 90%
              icon: Icons.science_rounded,
              color: Colors.green.shade700,
            ),
            // You can add more cards here (e.g., Pest Control)
          ],
        ),
      ),
    );
  }

  Widget _buildMonitoringCard(
    BuildContext context, {
    required String title,
    required String urduTitle,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                  Center(child: Icon(icon, color: color, size: 40)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.black),
                  ),
                  Text(
                    urduTitle,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppColors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${(value * 100).toInt()}% Used",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
