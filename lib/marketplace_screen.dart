// lib/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:farming/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BilingualText(
          englishText: "Marketplace",
          urduText: "منڈی",
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppColors.chocolateBrown,
            ),
            onPressed: () {
              /* Show filter options */
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sell My Crop Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const BilingualText(
                  englishText: "Sell My Crop",
                  urduText: "میری فصل بیچیں",
                  englishStyle: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  urduStyle: TextStyle(
                    color: AppColors.white,
                    fontFamily: 'NotoNastaliqUrdu',
                    fontSize: 18,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Market Trends / Best Deals
            Text(
              "Today's Rates | آج کے ریٹ",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Crop Card Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: 6, // Placeholder count
              itemBuilder: (context, index) {
                return _buildCropCard(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropCard(BuildContext context, int index) {
    // Placeholder data
    final crops = [
      {"name": "Wheat", "urdu": "گندم", "price": "Rs. 3900", "unit": "/ 40kg"},
      {"name": "Cotton", "urdu": "کپاس", "price": "Rs. 9500", "unit": "/ 40kg"},
      {"name": "Rice", "urdu": "چاول", "price": "Rs. 7200", "unit": "/ 40kg"},
      {"name": "Mango", "urdu": "آم", "price": "Rs. 200", "unit": "/ kg"},
      {"name": "Potato", "urdu": "آلو", "price": "Rs. 80", "unit": "/ kg"},
      {"name": "Onion", "urdu": "پیاز", "price": "Rs. 120", "unit": "/ kg"},
    ];
    final crop = crops[index % crops.length];

    final bool isBestDeal = index == 0; // Highlight first item as "best deal"

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isBestDeal
            ? BorderSide(color: AppColors.yellowGold, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Container(
              height: 100,
              color: Colors.grey.shade200,
              child: Center(
                child: Icon(Icons.image, color: Colors.grey.shade400, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop["name"]!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    crop["urdu"]!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    crop["price"]!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    crop["unit"]!,
                    style: Theme.of(context).textTheme.bodyMedium,
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
