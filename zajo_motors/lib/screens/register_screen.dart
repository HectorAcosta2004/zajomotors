import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Estos son tus controladores de texto
  final nombre = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final ApiService api = ApiService();

  bool loading = false;

  void registerUser() async {
    setState(() => loading = true);

    try {
      // 🔐 1. Crear usuario en FIREBASE
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 🌐 2. Guardar en MYSQL a través de tu API
      // Nota: Asegúrate de que el método en api_service.dart se llame registerUser
      final response = await api.registerUser({
        "uid": uid,
        "nombre": nombre.text.trim(),
        "email": email.text.trim(),
      });

      setState(() => loading = false);

      if (response != null && response["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        _showSnackBar(
          "Usuario creado en Firebase, pero falló el guardado en MySQL",
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      _showSnackBar("Error de Firebase: ${e.message}");
    } catch (e) {
      setState(() => loading = false);
      print(e);
      _showSnackBar("Error inesperado: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro Zajo Motors")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          // Para evitar error de pixeles si sale el teclado
          child: Column(
            children: [
              TextField(
                controller: nombre,
                decoration: const InputDecoration(labelText: "Nombre Completo"),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                ),
              ),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña"),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: loading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: Text(loading ? "Procesando..." : "Crear Cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
