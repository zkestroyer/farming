import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add user profile
  Future<void> addUser(
    String userId,
    String name,
    String phone,
    String role,
  ) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'phone': phone,
      'role': role,
      'location': {'lat': 0.0, 'long': 0.0},
      'preferences': [],
      'offlineData': true,
    });
  }

  // Get market data
  Future<List<Map<String, dynamic>>> getMarketData() async {
    QuerySnapshot snapshot = await _db.collection('market_data').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Get crop recommendations
  Future<List<Map<String, dynamic>>> getCropRecommendations() async {
    QuerySnapshot snapshot = await _db.collection('crop_recommendations').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Get tutorials
  Future<List<Map<String, dynamic>>> getTutorials() async {
    QuerySnapshot snapshot = await _db.collection('tutorials').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
