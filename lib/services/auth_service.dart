import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // AUTH AND FIRESTORE INSTANCE
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET CURRENT USER
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // LOGIN
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.code);
    }
  }

  // SIGNUP
  Future<UserCredential> createUserWithEmailPassword(
      String email, password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.code);
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
