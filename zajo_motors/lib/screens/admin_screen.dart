import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Panel Admin 👑",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _item(context, Icons.people, "Usuarios", "/usuarios"),
            _item(context, Icons.store, "Catálogo", "/catalogo_admin"),
            _item(context, Icons.location_on, "Sucursales", "/sucursales"),
            _item(context, Icons.attach_money, "Compras", "/compras"),
            _item(
              context,
              Icons.notifications,
              "Notificaciones",
              "/notificaciones",
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, route, arguments: {"from": "admin"}),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.shade100,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
