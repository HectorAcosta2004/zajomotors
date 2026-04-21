import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import 'tecnico_screen.dart';

final ApiService api = ApiService();
final FirebaseAuth auth = FirebaseAuth.instance;

void loginUser(String email, String password, context) async {
  try {
    // 🔐 1. LOGIN FIREBASE
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;

    // 🌐 2. ENVIAR A API
    final response = await api.loginWithUID(uid);

    if (response != null && response["success"] == true) {
      String rol = response["user"]["rol"];

      // 🚗 3. REDIRECCIÓN POR ROL
      if (rol == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminScreen()),
        );
      } else if (rol == "tecnico") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => TecnicoScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } else {
      print("Usuario no encontrado en MySQL");
    }
  } catch (e) {
    print("Error login: $e");
  }
}
