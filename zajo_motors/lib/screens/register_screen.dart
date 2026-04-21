import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombre = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final ApiService api = ApiService();

  bool loading = false;

  void registerUser() async {
    setState(() => loading = true);

    final response = await api.register(
      nombre.text.trim(),
      email.text.trim(),
      password.text.trim(),
    );

    setState(() => loading = false);

    if (response != null && response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado correctamente")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?["error"] ?? "Error registro")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
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
              onPressed: loading ? null : registerUser,
              child: Text(loading ? "Cargando..." : "Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}
