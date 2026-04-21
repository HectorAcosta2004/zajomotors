import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // REGISTER
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // SESIÓN ACTIVA
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
