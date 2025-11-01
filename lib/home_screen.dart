// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background with subtle wheat field art
        decoration: BoxDecoration(
          color: AppColors.warmBeige,
          // You would add your art here
          // image: DecorationImage(
          //   image: AssetImage("assets/images/wheat_field_bg.png"),
          //   fit: BoxFit.cover,
          //   opacity: 0.1,
          // ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Header
                _buildGreeting(context),
                const SizedBox(height: 24),

                // Weather Widget
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
                        /* Navigate or switch tab */
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.shopping_cart_rounded,
                      label: "Marketplace",
                      urduLabel: "منڈی",
                      color: AppColors.primaryRed,
                      onTap: () {
                        /* Navigate or switch tab */
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.school_rounded,
                      label: "Learning",
                      urduLabel: "سیکھیں",
                      color: AppColors.yellowGold,
                      onTap: () {
                        /* Navigate or switch tab */
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: "My Report",
                      urduLabel: "میری رپورٹ",
                      color: Colors.green.shade700,
                      onTap: () {
                        /* Navigate or switch tab */
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

  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome, Farmer!",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.chocolateBrown),
        ),
        Text(
          "خوش آمدید، کسان!",
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.chocolateBrown),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.wb_sunny_rounded, color: AppColors.yellowGold, size: 50),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "34°C - Sunny",
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: AppColors.black),
                  ),
                  Text(
                    "Lahore, Punjab",
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
