import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zajo_motors/screens/register_screen.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final ApiService api = ApiService();

  bool loading = false;

  void loginUser() async {
    setState(() => loading = true);

    try {
      // 🔐 1. LOGIN EN FIREBASE
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 🌐 2. CONSULTAR API (MYSQL)
      final response = await api.loginWithUID(uid);

      setState(() => loading = false);

      if (response != null && response["success"] == true) {
        String rol = response["user"]["rol"];

        // 🚗 3. REDIRECCIÓN POR ROL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );

        print("Usuario logueado con rol: $rol");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario no registrado en sistema")),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      print(e);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error login: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ZAJO MOTORS LOGIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : loginUser,
                child: Text(loading ? "Cargando..." : "Iniciar sesión"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  );
                },
                child: const Text(
                  "¿No tienes cuenta? Crear usuario",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
