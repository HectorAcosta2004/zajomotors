import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id") != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkLogin(),
      builder: (context, snapshot) {
        // ⏳ Loader moderno
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Usuario logueado
        if (snapshot.data == true) {
          return const HomeScreen();
        }

        // ❌ No logueado
        return const LoginScreen();
      },
    );
  }
}
