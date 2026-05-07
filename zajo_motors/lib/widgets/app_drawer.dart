import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/send_notification_screen.dart'; // Ajusta la ruta si es necesario

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String nombre = "";
  String rol = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nombre = prefs.getString("nombre") ?? "";
      rol = prefs.getString("rol") ?? "";
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // 🔥 HEADER MODERNO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    rol.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔽 MENÚ
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: buildMenu(),
              ),
            ),

            // 🔴 LOGOUT BONITO
            Padding(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tileColor: Colors.red[50],
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎯 MENÚ POR ROL
  List<Widget> buildMenu() {
    if (rol == "cliente") {
      return [
        item(Icons.store, "Catálogo", "/catalogo"),
        item(Icons.shopping_cart, "Mi carrito", "/carrito"),
        item(Icons.build, "Servicios", "/servicios"),
        item(Icons.history, "Historial", "/historial"),
        // 🔥 AÑADIDO: Sucursales para que el cliente las vea
        item(Icons.location_on, "Sucursales", "/sucursales"),
        item(Icons.notifications, "Notificaciones", "/notificaciones"),
        item(Icons.person, "Mi perfil", "/perfil"),
      ];
    }

    if (rol == "tecnico") {
      return [
        item(Icons.build_circle, "Órdenes", "/ordenes_tecnico"),
        item(Icons.notifications_active, "Notificaciones", "/notificaciones"),
        item(Icons.person, "Mi perfil", "/perfil"),
      ];
    }

    if (rol == "admin") {
      return [
        item(Icons.people, "Usuarios", "/usuarios"),
        item(Icons.store, "Catálogo", "/catalogo_admin"),
        item(Icons.location_on, "Sucursales", "/sucursales"),
        item(
          Icons.notifications_active,
          "Enviar Notificación",
          "/send_notification",
        ),
        item(Icons.attach_money, "Compras", "/compras"),
        item(Icons.notifications, "Notificaciones", "/notificaciones"),
        item(Icons.person, "Perfil", "/perfil"),
      ];
    }

    return [];
  }

  // 🎨 ITEM BONITO
  Widget item(IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.white,
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title),
        onTap: () {
          Navigator.pop(context); // Cierra el drawer primero
          Navigator.pushNamed(context, route); // Navega a la pantalla
        },
      ),
    );
  }
}
