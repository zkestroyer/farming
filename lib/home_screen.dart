// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart'; // This file should contain BilingualText
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farming/auth_screen.dart';
import 'learning_screen.dart';
import 'marketplace_screen.dart';
import 'smart_farming_screen.dart';
// --- 1. IMPORT YOUR SERVICE AND MODELS ---
import 'package:farming/services/weather_service.dart';
import 'package:farming/models/weather_models.dart';

// --- 2. BilingualText class REMOVED ---
// It's already imported from 'app_theme.dart'

class HomeScreen extends StatelessWidget {
  // --- ADDED const constructor ---
  HomeScreen({super.key});

  // --- 3. CREATE AN INSTANCE OF THE SERVICE ---
  final WeatherService _weatherService = WeatherService();

  // --- 4. LOGOUT FUNCTION ---
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- 5. ADDED APPBAR WITH LOGOUT ---
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome, Farmer!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.chocolateBrown,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "خوش آمدید، کسان!",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: Icon(Icons.logout, color: AppColors.chocolateBrown),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.warmBeige),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting is now in the AppBar, so we don't need it here
                // _buildGreeting(context), <-- REMOVED
                // const SizedBox(height: 24), <-- REMOVED

                // --- 6. WEATHER WIDGET (NOW USES FUTUREBUILDER) ---
                _buildWeatherWidget(context),
                const SizedBox(height: 24),

                // Quick Action Grid
                Text(
                  "Quick Actions | فوری کاروائیاں",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.agriculture_rounded,
                      label: "Smart Farm",
                      urduLabel: "سمارٹ فارم",
                      color: AppColors.chocolateBrown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SmartFarmingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.shopping_cart_rounded,
                      label: "Marketplace",
                      urduLabel: "منڈی",
                      color: AppColors.primaryRed,
                      onTap: () {},
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.school_rounded,
                      label: "Learning",
                      urduLabel: "سیکھیں",
                      color: AppColors.yellowGold,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LearningScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: "My Report",
                      urduLabel: "میری رپورٹ",
                      color: Colors.green.shade700,
                      onTap: () {
                        // Navigate to reports screen
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 7. HELPER FUNCTIONS FOR WEATHER ICONS ---
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.wb_cloudy_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.foggy;
      default:
        return Icons.wb_sunny_rounded; // Default to sunny
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return AppColors.yellowGold;
      case 'clouds':
        return Colors.grey.shade600;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return Colors.blue.shade700;
      case 'snow':
        return Colors.lightBlue.shade200;
      default:
        return AppColors.yellowGold;
    }
  }

  // --- 8. THE WEATHER WIDGET, NOW POWERED BY A FUTUREBUILDER ---
  Widget _buildWeatherWidget(BuildContext context) {
    return FutureBuilder<Weather>(
      future: _weatherService.getForecast("Lahore"), // API call
      builder: (context, snapshot) {
        // --- A. LOADING STATE ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircularProgressIndicator(color: AppColors.primaryRed),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Loading Weather...",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.black),
                        ),
                        Text(
                          "Please wait",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // --- B. ERROR STATE ---
        if (snapshot.hasError) {
          return Card(
            elevation: 2,
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.primaryRed,
                    size: 50,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Weather Error",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.black),
                        ),
                        Text(
                          "Could not load data.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // --- C. SUCCESS STATE ---
        if (snapshot.hasData) {
          final weather = snapshot.data!;
          final today = weather.dailyForecasts[0];
          final icon = _getWeatherIcon(weather.currentCondition);
          final color = _getWeatherColor(weather.currentCondition);

          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 50),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${weather.currentTemp.round()}°C - ${weather.currentCondition}",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppColors.black),
                        ),
                        Text(
                          weather.locationName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          "H: ${today.maxTemp.round()}° / L: ${today.minTemp.round()}°",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.chocolateBrown,
                  ),
                ],
              ),
            ),
          );
        }

        // Default case
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // --- 9. ACTION CARD BUILDER (NO CHANGES) ---
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String urduLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              BilingualText(
                englishText: label,
                urduText: urduLabel,
                englishStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                urduStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
