// lib/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farming/app_theme.dart';

class MarketplaceScreen extends StatefulWidget {
  final String? initialTab; // NEW: allows opening a specific section

  const MarketplaceScreen({super.key, this.initialTab});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Scroll to initial section after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialTab == "sellCrop") {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (widget.initialTab == "tutorials") {
        _scrollController.animateTo(
          500, // adjust according to layout
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        controller: _scrollController, // attach controller
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sell My Crop Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Scroll to sell crop section or show form
                  // Here it's already top, you could open a modal if needed
                },
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
                        onTap: () {
                          // TODO: Show crop details
                        },
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
                          // TODO: Open video URL
                          final url = tutorial['videoUrl'] ?? "";
                          if (url.isNotEmpty) {
                            // Use url_launcher
                            // launchUrl(Uri.parse(url));
                          }
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
