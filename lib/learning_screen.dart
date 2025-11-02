import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  void _launchLesson(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BilingualText(
          englishText: "Learning Hub",
          urduText: "سیکھنے کا مرکز",
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildLearningCard(
            context,
            title: "Water Saving",
            urduTitle: "پانی کی بچت",
            icon: Icons.water_damage_rounded,
            color: Colors.blue.shade700,
            lessonUrl: "https://www.youtube.com/watch?v=U0f0u1A0aQ4",
          ),
          _buildLearningCard(
            context,
            title: "Modern Farming",
            urduTitle: "جدید کاشتکاری",
            icon: Icons.agriculture_rounded,
            color: Colors.green.shade800,
            lessonUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
          ),
          _buildLearningCard(
            context,
            title: "Sustainable Methods",
            urduTitle: "پائیدار طریقے",
            icon: Icons.eco_rounded,
            color: AppColors.chocolateBrown,
            lessonUrl: "https://www.youtube.com/watch?v=J---aiyznGQ",
          ),
          _buildLearningCard(
            context,
            title: "Pest Control",
            urduTitle: "کیڑوں پر قابو پانا",
            icon: Icons.bug_report_rounded,
            color: AppColors.primaryRed,
            lessonUrl: "https://www.youtube.com/watch?v=oHg5SJYRHA0",
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard(
    BuildContext context, {
    required String title,
    required String urduTitle,
    required IconData icon,
    required Color color,
    required String lessonUrl,
  }) {
    return Card(
      child: InkWell(
        onTap: () => _launchLesson(lessonUrl),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      urduTitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.play_circle_fill_rounded,
                  color: AppColors.primaryRed,
                  size: 40,
                ),
                onPressed: () => _launchLesson(lessonUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
