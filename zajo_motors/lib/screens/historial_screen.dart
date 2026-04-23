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
  final ApiService api = ApiService();

  List ordenes = [];
  bool loading = true;
  int usuarioId = 0;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  void cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getInt("id") ?? 0;

    cargarHistorial();
  }

  void cargarHistorial() async {
    final data = await api.getHistorial(usuarioId);

    setState(() {
      ordenes = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de compras 📦")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ordenes.isEmpty
          ? const Center(child: Text("No hay compras"))
          : ListView.builder(
              itemCount: ordenes.length,
              itemBuilder: (context, index) {
                final orden = ordenes[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Orden #${orden["id"]}"),
                    subtitle: Text(
                      "Estado: ${orden["estado"]} | Total: \$${orden["total"]}",
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetalleOrdenScreen(ordenId: orden["id"]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
