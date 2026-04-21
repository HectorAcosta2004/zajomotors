import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (e) {
    print("Error crítico al inicializar Firebase: $e");

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              "Error de conexión: $e",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return MaterialApp(
      title: 'Zajo Motors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // 🔥 AQUÍ ESTÁ LA MAGIA
      home: auth.getCurrentUser() != null ? HomeScreen() : LoginScreen(),
    );
  }
}
