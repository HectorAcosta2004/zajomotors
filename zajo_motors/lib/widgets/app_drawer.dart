import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart'; // Para el logout limpio

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

    // Desvinculamos OneSignal para que no lleguen notificaciones de este usuario
    OneSignal.logout();

    Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // HEADER CON GRADIENTE
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

            // LISTADO DE OPCIONES
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: buildMenu(),
              ),
            ),

            // BOTÓN DE LOGOUT
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
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildMenu() {
    if (rol == "cliente") {
      return [
        item(Icons.store, "Catálogo", "/catalogo"),
        item(Icons.shopping_cart, "Mi carrito", "/carrito"),
        item(Icons.build, "Servicios", "/servicios"),
        item(Icons.history, "Historial de Órdenes", "/historial"),
        item(Icons.location_on, "Sucursales", "/sucursales"),
        item(Icons.notifications, "Notificaciones", "/notificaciones"),
        item(Icons.person, "Mi perfil", "/perfil"),
      ];
    }

    if (rol == "tecnico") {
      return [
        item(Icons.build_circle, "Órdenes Asignadas", "/ordenes_tecnico"),
        item(
          Icons.person_pin,
          "Notificar a Cliente",
          "/notificaciones_servicio",
        ),
        item(Icons.person, "Mi perfil", "/perfil"),
      ];
    }

    if (rol == "admin") {
      return [
        // CORREGIDO: Icono de gráficas y ruta al Dashboard
        item(Icons.bar_chart_rounded, "Dashboard / Gráficas", "/admin"),
        item(Icons.people, "Gestión de Usuarios", "/usuarios"),
        item(Icons.store, "Catálogo Admin", "/catalogo_admin"),
        item(Icons.location_on, "Sucursales", "/sucursales"),
        item(
          Icons.notifications_active,
          "Enviar Notificación",
          "/send_notification",
        ),
        item(Icons.attach_money, "Reporte de Compras", "/compras"),
        item(Icons.history, "Historial Notificaciones", "/notificaciones"),
        item(Icons.person, "Perfil", "/perfil"),
      ];
    }

    return [];
  }

  Widget item(IconData icon, String title, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.white,
        leading: Icon(icon, color: const Color(0xFF2C5364)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        onTap: () {
          Navigator.pop(context); // Cierra el drawer
          Navigator.pushNamed(context, route); // Navega
        },
      ),
    );
  }
}
