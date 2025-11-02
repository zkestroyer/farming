// lib/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farming/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  // --- Sell Crop Bottom Sheet ---
  void _showSellCropSheet(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController urduController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController unitController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Sell Your Crop | اپنی فصل بیچیں",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Crop Name (English)",
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: urduController,
                  decoration: const InputDecoration(labelText: "نام (Urdu)"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price (PKR)"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: "Unit (kg/lb)"),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        unitController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all required fields"),
                        ),
                      );
                      return;
                    }

                    // Save to Firestore
                    await FirebaseFirestore.instance
                        .collection('crop_recommendations')
                        .add({
                          'name': nameController.text.trim(),
                          'urdu': urduController.text.trim(),
                          'price': priceController.text.trim(),
                          'unit': unitController.text.trim(),
                          'createdAt': DateTime.now(),
                        });

                    Navigator.pop(context); // Close bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Crop added successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Add Crop"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Crop Detail Bottom Sheet ---
  void _showCropDetail(BuildContext context, Map<String, dynamic> crop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                crop['name'] ?? "Crop",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                crop['urdu'] ?? "",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                "Price: ${crop['price'] ?? '-'} / ${crop['unit'] ?? '-'}",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primaryRed),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

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
              // TODO: Show filter options
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sell My Crop Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSellCropSheet(context),
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

            // Crop Recommendations
            Text(
              "Today's Crop Recommendations | آج کی فصل کی سفارشات",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('crop_recommendations')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final crops = snapshot.data!.docs;
                if (crops.isEmpty) {
                  return const Text("No recommendations available.");
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: crops.length,
                  itemBuilder: (context, index) {
                    final crop = crops[index].data() as Map<String, dynamic>;
                    final bool isBestDeal = index == 0;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isBestDeal
                            ? BorderSide(color: AppColors.yellowGold, width: 3)
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        onTap: () => _showCropDetail(context, crop),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 100,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    crop['name'] ?? "Crop",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    crop['urdu'] ?? "",
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    crop['price'] ?? "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.primaryRed,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    crop['unit'] ?? "",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Market Tutorials Section
            Text(
              "Learning & Tutorials | سیکھیں اور تربیت",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('market_tutorials')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tutorials = snapshot.data!.docs;
                if (tutorials.isEmpty) {
                  return const Text("No tutorials available.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tutorials.length,
                  itemBuilder: (context, index) {
                    final tutorial =
                        tutorials[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(tutorial['title'] ?? "Tutorial"),
                        subtitle: Text(tutorial['urdu'] ?? ""),
                        onTap: () {
                          // TODO: Show tutorial detail
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
