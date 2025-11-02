// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // <-- IMPORT THIS
import 'package:flutter/foundation.dart'; // <-- IMPORT THIS

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance; // <-- ADD THIS

  // --- ADD THIS BLOCK to use local emulators ---
  FirebaseService() {
    if (kDebugMode) {
      _functions.useFunctionsEmulator('127.0.0.1', 5001);
    }
  }
  // --- END BLOCK ---


  // Add or update user profile
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Write an AI query. The cloud function will add the response.
  Future<DocumentReference> addQuery(String uid, String question) async {
    return await _db.collection('queries').add({
      'userID': uid,
      'question': question,
      'aiResponse': null,
      'status': 'processing',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- MODIFIED: Reads from 'market_rates' (which our function now writes to) ---
  Stream<List<Map<String, dynamic>>> marketRatesStream(String region) {
    return _db
        .collection('market_rates')
        .where('region', isEqualTo: region)
        // .orderBy("lastUpdated", descending: true) // Good to add
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // Add resource
  Future<void> addResource(Map<String, dynamic> resource) async {
    await _db.collection('resources').add(resource);
  }

  // --- NEW FUNCTION 1: Call 'postCropForSale' ---
  Future<HttpsCallableResult> postCropForSale({
    required String cropName,
    required String urduName,
    required double quantity,
    required double price,
    required String unit,
  }) async {
    final callable = _functions.httpsCallable('postCropForSale');
    return await callable.call(<String, dynamic>{
      'cropName': cropName,
      'urduName': urduName,
      'quantity': quantity,
      'price': price,
      'unit': unit,
    });
  }

  // --- NEW FUNCTION 2: Call 'updateMarketRates' (for admin) ---
  Future<HttpsCallableResult> updateMarketRates(List<Map<String, dynamic>> rates) async {
    final callable = _functions.httpsCallable('updateMarketRates');
    return await callable.call(<String, dynamic>{
      'rates': rates,
    });
  }

  // --- NEW: A simple stream to read the crops for sale ---
  Stream<QuerySnapshot> getCropsForSaleStream() {
    return _db
        .collection("crops_for_sale")
        .where("status", isEqualTo: "available")
        .orderBy("postedAt", descending: true)
        .snapshots();
  }
}