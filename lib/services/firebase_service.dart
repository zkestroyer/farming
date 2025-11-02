// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  FirebaseService() {
    // Use local emulators in debug mode
    if (kDebugMode) {
      try {
        _functions.useFunctionsEmulator('localhost', 5001);
        _db.useFirestoreEmulator('localhost', 8080);
      } catch (e) {
        debugPrint('Emulator connection error: $e');
      }
    }
  }

  // ============= USER MANAGEMENT =============
  
  /// Add or update user profile
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error setting user profile: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Stream user profile
  Stream<DocumentSnapshot> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // ============= AI QUERIES =============

  /// Write an AI query. The cloud function will add the response.
  Future<DocumentReference> addQuery(String uid, String question) async {
    try {
      return await _db.collection('queries').add({
        'userID': uid,
        'question': question,
        'aiResponse': null,
        'status': 'processing',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding query: $e');
      rethrow;
    }
  }

  /// Get a specific query by ID
  Stream<DocumentSnapshot> getQueryStream(String queryId) {
    return _db.collection('queries').doc(queryId).snapshots();
  }

  /// Get user's query history
  Stream<QuerySnapshot> getUserQueriesStream(String uid, {int limit = 20}) {
    return _db
        .collection('queries')
        .where('userID', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ============= MARKET RATES =============

  /// Stream market rates for a specific region
  Stream<List<Map<String, dynamic>>> marketRatesStream(String region) {
    return _db
        .collection('market_rates')
        .where('region', isEqualTo: region)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Get all market rates (for all regions)
  Stream<QuerySnapshot> getAllMarketRatesStream() {
    return _db
        .collection('market_rates')
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  /// Call cloud function to update market rates (admin only)
  Future<Map<String, dynamic>> updateMarketRates(
      List<Map<String, dynamic>> rates) async {
    try {
      final callable = _functions.httpsCallable('updateMarketRates');
      final result = await callable.call(<String, dynamic>{
        'rates': rates,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error updating market rates: $e');
      rethrow;
    }
  }

  // ============= CROPS FOR SALE =============

  /// Post a crop for sale
  Future<Map<String, dynamic>> postCropForSale({
    required String cropName,
    required String urduName,
    required double quantity,
    required double price,
    required String unit,
    String? description,
    String? location,
  }) async {
    try {
      final callable = _functions.httpsCallable('postCropForSale');
      final result = await callable.call(<String, dynamic>{
        'cropName': cropName,
        'urduName': urduName,
        'quantity': quantity,
        'price': price,
        'unit': unit,
        'description': description,
        'location': location,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error posting crop for sale: $e');
      rethrow;
    }
  }

  /// Get all available crops for sale
  Stream<QuerySnapshot> getCropsForSaleStream({int limit = 50}) {
    return _db
        .collection('crops_for_sale')
        .where('status', isEqualTo: 'available')
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Get crops for sale by specific seller
  Stream<QuerySnapshot> getSellerCropsStream(String sellerId) {
    return _db
        .collection('crops_for_sale')
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('postedAt', descending: true)
        .snapshots();
  }

  /// Search crops by name
  Stream<QuerySnapshot> searchCrops(String searchTerm) {
    return _db
        .collection('crops_for_sale')
        .where('status', isEqualTo: 'available')
        .orderBy('postedAt', descending: true)
        .snapshots();
    // Note: Firestore doesn't support case-insensitive search
    // You'll need to filter results on the client side
  }

  /// Mark a crop as sold
  Future<Map<String, dynamic>> markCropAsSold(String cropId) async {
    try {
      final callable = _functions.httpsCallable('markCropAsSold');
      final result = await callable.call(<String, dynamic>{
        'cropId': cropId,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error marking crop as sold: $e');
      rethrow;
    }
  }

  /// Delete a crop listing
  Future<Map<String, dynamic>> deleteCropListing(String cropId) async {
    try {
      final callable = _functions.httpsCallable('deleteCropListing');
      final result = await callable.call(<String, dynamic>{
        'cropId': cropId,
      });
      return result.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error deleting crop listing: $e');
      rethrow;
    }
  }

  /// Increment views for a crop listing
  Future<void> incrementCropViews(String cropId) async {
    try {
      await _db.collection('crops_for_sale').doc(cropId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing crop views: $e');
      // Don't rethrow - views are not critical
    }
  }

  // ============= RESOURCES =============

  /// Add a farming resource
  Future<void> addResource(Map<String, dynamic> resource) async {
    try {
      await _db.collection('resources').add({
        ...resource,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding resource: $e');
      rethrow;
    }
  }

  /// Get resources stream
  Stream<QuerySnapshot> getResourcesStream({String? category}) {
    Query query = _db.collection('resources');
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // ============= NOTIFICATIONS =============

  /// Get user notifications
  Stream<QuerySnapshot> getUserNotificationsStream(String uid, {int limit = 20}) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }
}