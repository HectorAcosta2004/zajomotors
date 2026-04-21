import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'detalle_orden_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final api = ApiService();
  List ordenes = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("id") ?? 0;

    final data = await api.getOrdenes(id);

    setState(() {
      ordenes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial 📦")),
      body: ListView.builder(
        itemCount: ordenes.length,
        itemBuilder: (context, i) {
          final o = ordenes[i];

          return ListTile(
            title: Text("Orden #${o["id"]}"),
            subtitle: Text("Total: \$${o["total"]} | ${o["estado"]}"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleOrdenScreen(ordenId: o["id"]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
