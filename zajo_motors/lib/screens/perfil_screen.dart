import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String nombre = "";
  String email = "";
  String rol = "";

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  void cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nombre = prefs.getString("nombre") ?? "";
      email = prefs.getString("email") ?? "";
      rol = prefs.getString("rol") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person, size: 100),
            const SizedBox(height: 20),
            Text("Nombre: $nombre"),
            Text("Email: $email"),
            Text("Rol: $rol"),
          ],
        ),
      ),
    );
  }
}
