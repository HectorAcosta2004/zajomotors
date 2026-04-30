import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/main_layout.dart';
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

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  void cargarHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt("id") ?? 0;

    if (usuarioId != 0) {
      final data = await api.getHistorial(usuarioId);
      setState(() {
        ordenes = data;
        loading = false;
      });
    }
  }

  Color getStatusColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'terminado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Mi Historial",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ordenes.isEmpty
          ? const Center(
              child: Text("Aún no tienes compras o servicios agendados."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ordenes.length,
              itemBuilder: (context, index) {
                final o = ordenes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor(o["estado"]),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "Orden #${o["id"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha: ${o["fecha"].toString().split('T')[0]}"),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getStatusColor(o["estado"]).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            o["estado"].toString().toUpperCase(),
                            style: TextStyle(
                              color: getStatusColor(o["estado"]),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "\$${o["total"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleOrdenScreen(ordenId: o["id"]),
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
