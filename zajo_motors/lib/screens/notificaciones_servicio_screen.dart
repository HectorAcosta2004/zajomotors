import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'notificar_servicio_screen.dart'; // Importación correcta del formulario

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
      final data = await api.getOrdenesTecnico();

      setState(() {
        _pendientes = data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar clientes: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Seleccionar Cliente"),
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendientes.isEmpty
          ? const Center(child: Text("No hay clientes con servicios activos"))
          : RefreshIndicator(
              onRefresh: () async => _fetchPendientes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _pendientes.length,
                itemBuilder: (context, index) {
                  final item = _pendientes[index];

                  // Mapeo de datos desde la base de datos
                  String nombreCliente =
                      item['cliente_nombre'] ??
                      item['nombre'] ??
                      "Cliente #${item['usuario_id']}";
                  String nombreServicio =
                      item['servicio_nombre'] ??
                      item['servicio'] ??
                      "Servicio General";

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2C5364),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        nombreCliente,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "🛠️ Servicio: $nombreServicio",
                          style: TextStyle(color: Colors.blueGrey[700]),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificarServicioScreen(
                              clienteId: item['usuario_id']
                                  .toString(), // Debe coincidir con el SELECT
                              clienteNombre:
                                  item['cliente_nombre'], // Debe coincidir con el SELECT
                              servicioNombre:
                                  item['servicio_nombre'], // Debe coincidir con el SELECT
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
