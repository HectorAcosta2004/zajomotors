import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔐 Verificar sesión guardada
  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id") != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          // ⏳ Mientras carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ Si hay sesión
          if (snapshot.data == true) {
            return const HomeScreen();
          }

          // ❌ Si NO hay sesión
          return const LoginScreen();
        },
      ),
    );
  }
}
