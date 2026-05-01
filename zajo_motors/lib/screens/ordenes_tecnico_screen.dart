import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detalle_orden_screen.dart';

class OrdenesTecnicoScreen extends StatefulWidget {
  const OrdenesTecnicoScreen({super.key});

  @override
  State<OrdenesTecnicoScreen> createState() => _OrdenesTecnicoScreenState();
}

class _OrdenesTecnicoScreenState extends State<OrdenesTecnicoScreen> {
  final ApiService api = ApiService();
  List ordenes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarOrdenesDeTrabajo();
  }

  void cargarOrdenesDeTrabajo() async {
    setState(() => loading = true);
    // Reutilizamos la función que ya trae todas las órdenes con el nombre del cliente
    final data = await api.getTodasLasOrdenes();
    setState(() {
      // Opcional: Podríamos filtrar para no mostrar las "canceladas",
      // pero por ahora mostraremos todas para que tenga el historial completo.
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

  void _actualizarEstado(int ordenId, String nuevoEstado, int index) async {
    // Actualización instantánea en pantalla
    setState(() {
      ordenes[index]["estado"] = nuevoEstado;
    });

    // Petición al servidor
    bool ok = await api.cambiarEstadoOrden(ordenId, nuevoEstado);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Estatus actualizado a: ${nuevoEstado.toUpperCase()}"),
          backgroundColor: _getColorEstado(nuevoEstado),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      cargarOrdenesDeTrabajo(); // Revertir si hay error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cola de Trabajo (Técnico)"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ordenes.isEmpty
          ? const Center(
              child: Text("No hay trabajos pendientes. ¡Tómate un café! ☕"),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: ordenes.length,
              itemBuilder: (context, index) {
                final o = ordenes[index];
                String estadoActual = o["estado"].toString().toLowerCase();

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: _getColorEstado(estadoActual),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila de ID y Estado visual
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Orden de Trabajo #${o["id"]}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              label: Text(
                                estadoActual.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: _getColorEstado(estadoActual),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const Divider(),

                        // Datos del Cliente y Fecha
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.indigo,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Cliente: ${o["cliente_nombre"] ?? 'Desconocido'}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Fecha de solicitud: ${o["fecha"].toString().split('T')[0]}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Acciones: Cambiar estado y ver tareas
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dropdown para avanzar el trabajo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
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
                                      child: Text("Pendiente 🕒"),
                                    ),
                                    DropdownMenuItem(
                                      value: "en proceso",
                                      child: Text("En Proceso 🔧"),
                                    ),
                                    DropdownMenuItem(
                                      value: "terminado",
                                      child: Text("Terminado ✅"),
                                    ),
                                    // 🔥 AQUÍ ESTÁ EL ARREGLO PARA LA PANTALLA ROJA
                                    DropdownMenuItem(
                                      value: "cancelado",
                                      child: Text("Cancelado ❌"),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _actualizarEstado(o["id"], val, index);
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Botón para ver qué herramientas/piezas necesita
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
                              icon: const Icon(Icons.build),
                              label: const Text("Ver Tareas"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
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
