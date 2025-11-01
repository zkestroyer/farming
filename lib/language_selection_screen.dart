// lib/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'package:farming/main_scaffold.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _selectLanguage(BuildContext context) {
    // In a real app, you would save this choice (e.g., SharedPreferences)
    // and set the app's locale.
    // For this demo, we just navigate to the home screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Soft yellow + beige background with subtle texture
        decoration: BoxDecoration(
          color: AppColors.warmBeige,
          // You could add a subtle pattern here:
          // image: DecorationImage(
          //   image: AssetImage('assets/images/farm_texture.png'),
          //   fit: BoxFit.cover,
          //   opacity: 0.1,
          // ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo of Verda (leaf + soil + sun shape)
              // Placeholder for your logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.chocolateBrown.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.eco, // Placeholder icon
                    size: 70,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Verda",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.chocolateBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                "Select Language | زبان منتخب کریں",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.chocolateBrown,
                ),
              ),
              Text(
                "زبان منتخب کریں",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 40),

              // Language Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLanguageButton(
                    context,
                    label: "English",
                    flag: "🇬🇧", // Placeholder
                    onTap: () => _selectLanguage(context),
                  ),
                  _buildLanguageButton(
                    context,
                    label: "Urdu",
                    flag: "🇵🇰", // Placeholder
                    onTap: () => _selectLanguage(context),
                  ),
                  _buildLanguageButton(
                    context,
                    label: "Punjabi",
                    flag: "🌾", // Placeholder
                    onTap: () => _selectLanguage(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context, {
    required String label,
    required String flag,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: AppColors.white,
            padding: const EdgeInsets.all(24),
            elevation: 3,
          ),
          child: Text(flag, style: const TextStyle(fontSize: 40)),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.chocolateBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
