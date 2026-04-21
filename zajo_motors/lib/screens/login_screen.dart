import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'home_screen.dart';
import 'admin_screen.dart';
import 'tecnico_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final ApiService api = ApiService();

  bool loading = false;

  // 🔐 LOGIN
  void loginUser() async {
    setState(() => loading = true);

    final response = await api.login(email.text.trim(), password.text.trim());

    setState(() => loading = false);

    if (response != null && response["success"] == true) {
      final user = response["user"];
      String rol = user["rol"];

      // 💾 GUARDAR SESIÓN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("id", user["id"]);
      await prefs.setString("nombre", user["nombre"]);
      await prefs.setString("email", user["email"]);
      await prefs.setString("rol", rol);

      // 🚦 REDIRECCIÓN POR ROL
      if (rol == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminScreen()),
        );
      } else if (rol == "tecnico") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TecnicoScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?["error"] ?? "Error login")),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "ZAJO MOTORS",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : loginUser,
                  child: Text(loading ? "Cargando..." : "Iniciar sesión"),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Crear cuenta"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
