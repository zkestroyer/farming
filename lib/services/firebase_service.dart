import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add or update user profile
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Write an AI query + response
  Future<void> addQuery(String uid, String question, String response) async {
    await _db.collection('queries').add({
      'userID': uid,
      'question': question,
      'aiResponse': response,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Read market rates stream
  Stream<List<Map<String, dynamic>>> marketRatesStream(String region) {
    return _db
        .collection('market_rates')
        .where('region', isEqualTo: region)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // Add resource
  Future<void> addResource(Map<String, dynamic> resource) async {
    await _db.collection('resources').add(resource);
  }
}
