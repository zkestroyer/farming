import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart'; // your Firestore helper

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _fs = FirestoreService();

  User? get currentUser => _auth.currentUser;

  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? user = res.user;

    if (user != null) {
      await _fs.addUser(user.uid, name, phone, "farmer");
    }

    return user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  Future<void> signOut() async => await _auth.signOut();
}
