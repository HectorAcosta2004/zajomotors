import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detalle_orden_screen.dart';

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  State<ComprasScreen> createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  final ApiService api = ApiService();
  List ordenes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarTodasLasOrdenes();
  }

  void cargarTodasLasOrdenes() async {
    setState(() => loading = true);
    final data = await api.getTodasLasOrdenes();
    setState(() {
      ordenes = data;
      loading = false;
    });
  }

  Color _getColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'terminado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _actualizarEstado(int ordenId, String nuevoEstado) async {
    bool ok = await api.cambiarEstadoOrden(ordenId, nuevoEstado);
    if (ok) {
      cargarTodasLasOrdenes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Estado actualizado y cliente notificado"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial Global de Ventas"),
        backgroundColor: const Color(0xFF2C5364),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ordenes.isEmpty
          ? const Center(child: Text("No se han realizado ventas aún."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ordenes.length,
              itemBuilder: (context, index) {
                final o = ordenes[index];
                String estadoActual = o["estado"].toString().toLowerCase();

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Orden #${o["id"]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${o["total"]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 5),
                        // Mostramos el nombre que trajimos con el JOIN
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Cliente: ${o["cliente_nombre"] ?? 'Usuario Desconocido'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Fecha: ${o["fecha"].toString().split('T')[0]}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Selector de Estado
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getColorEstado(estadoActual),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value:
                                      [
                                        "pendiente",
                                        "en proceso",
                                        "terminado",
                                        "cancelado",
                                      ].contains(estadoActual)
                                      ? estadoActual
                                      : "pendiente",
                                  items: const [
                                    DropdownMenuItem(
                                      value: "pendiente",
                                      child: Text("Pendiente"),
                                    ),
                                    DropdownMenuItem(
                                      value: "en proceso",
                                      child: Text("En Proceso"),
                                    ),
                                    DropdownMenuItem(
                                      value: "terminado",
                                      child: Text("Terminado"),
                                    ),
                                    DropdownMenuItem(
                                      value: "cancelado",
                                      child: Text("Cancelado"),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      _actualizarEstado(o["id"], val!),
                                ),
                              ),
                            ),
                            // Botón de Detalle
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetalleOrdenScreen(ordenId: o["id"]),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.list_alt),
                              label: const Text("Ver Detalle"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
