import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catalogo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String rol = "";

  @override
  void initState() {
    super.initState();
    cargarRol();
  }

  void cargarRol() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rol = prefs.getString("rol") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zajo Motors 🚗")),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Menú")),

            // 👤 CLIENTE
            if (rol == "cliente") ...[
              ListTile(
                title: const Text("Catálogo"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CatalogoScreen()),
                  );
                },
              ),
              ListTile(title: const Text("Carrito"), onTap: () {}),
              ListTile(title: const Text("Servicios"), onTap: () {}),
            ],

            // 🔧 TECNICO
            if (rol == "tecnico") ...[
              ListTile(title: const Text("Servicios pendientes"), onTap: () {}),
            ],

            // 👑 ADMIN
            if (rol == "admin") ...[
              ListTile(title: const Text("Usuarios"), onTap: () {}),
              ListTile(title: const Text("Compras"), onTap: () {}),
            ],

            const Divider(),

            ListTile(
              title: const Text("Cerrar sesión"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: Text(
          "Bienvenido ($rol) 🚗",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
