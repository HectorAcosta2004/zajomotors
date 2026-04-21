import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      child: ListView(
        children: [
          // 🔵 HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            accountName: Text(nombre),
            accountEmail: Text(rol.toUpperCase()),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person, size: 40),
            ),
          ),

          // 🔽 MENÚ DINÁMICO
          ...buildMenu(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Cerrar sesión"),
            onTap: logout,
          ),
        ],
      ),
    );
  }

  // 🔥 MENÚ SEGÚN ROL
  List<Widget> buildMenu() {
    if (rol == "cliente") {
      return [
        item(Icons.store, "Catálogo"),
        item(Icons.shopping_cart, "Mi carrito"),
        item(Icons.build, "Servicios"),
        item(Icons.history, "Historial"), // ✅ NUEVO
        item(Icons.notifications, "Notificaciones"),
        item(Icons.person, "Mi perfil"),
      ];
    }

    if (rol == "tecnico") {
      return [
        item(Icons.assignment, "Órdenes"), // ✅ mejor nombre
        item(Icons.check_circle, "Finalizados"),
        item(Icons.notifications_active, "Notificaciones"),
        item(Icons.person, "Mi perfil"),
      ];
    }

    if (rol == "admin") {
      return [
        item(Icons.people, "Usuarios"),
        item(Icons.store, "Catálogo"),
        item(Icons.location_on, "Sucursales"),
        item(Icons.receipt_long, "Compras"),
        item(Icons.notifications, "Notificaciones"),
        item(Icons.person, "Perfil"),
      ];
    }

    return [];
  }

  // 🔘 ITEM GENERICO
  Widget item(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        navigate(title);
      },
    );
  }

  // 🚀 NAVEGACIÓN
  void navigate(String title) {
    switch (title) {
      // CLIENTE
      case "Catálogo":
        Navigator.pushNamed(context, "/catalogo");
        break;

      case "Mi carrito":
        Navigator.pushNamed(context, "/carrito");
        break;

      case "Servicios":
        Navigator.pushNamed(context, "/servicios");
        break;

      case "Historial":
        Navigator.pushNamed(context, "/historial");
        break;

      case "Notificaciones":
        Navigator.pushNamed(context, "/notificaciones");
        break;

      case "Mi perfil":
      case "Perfil":
        Navigator.pushNamed(context, "/perfil");
        break;

      // TECNICO
      case "Órdenes":
        Navigator.pushNamed(context, "/ordenes_tecnico");
        break;

      case "Finalizados":
        Navigator.pushNamed(context, "/ordenes_finalizadas");
        break;

      // ADMIN
      case "Usuarios":
        Navigator.pushNamed(context, "/usuarios");
        break;

      case "Sucursales":
        Navigator.pushNamed(context, "/sucursales");
        break;

      case "Compras":
        Navigator.pushNamed(context, "/compras");
        break;
    }
  }
}
