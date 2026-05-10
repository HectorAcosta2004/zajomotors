import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'enviar_notificacion_detalle_screen.dart';

class NotificacionesServicioScreen extends StatefulWidget {
  const NotificacionesServicioScreen({super.key});

  @override
  State<NotificacionesServicioScreen> createState() =>
      _NotificacionesServicioScreenState();
}

class _NotificacionesServicioScreenState
    extends State<NotificacionesServicioScreen> {
  final ApiService api = ApiService();
  List<dynamic> _pendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendientes();
  }

  void _fetchPendientes() async {
    setState(() => _isLoading = true);
    try {
      // Este método debe retornar la lista de órdenes con nombres de clientes y servicios
      final data = await api.getOrdenesTecnico();
      setState(() {
        _pendientes = data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seleccionar Cliente")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pendientes.length,
              itemBuilder: (context, index) {
                final item = _pendientes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      item['cliente_nombre'] ??
                          "Cliente #${item['usuario_id']}",
                    ),
                    subtitle: Text(
                      "Servicio: ${item['servicio_nombre'] ?? 'General'}",
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Al seleccionar, vamos a la vista de envío pasando los datos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EnviarNotificacionDetalleScreen(
                            clienteId: item['usuario_id'].toString(),
                            clienteNombre: item['cliente_nombre'] ?? "Cliente",
                            servicioNombre:
                                item['servicio_nombre'] ?? "Servicio",
                          ),
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
