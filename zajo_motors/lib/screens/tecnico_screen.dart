import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart'; // Asegúrate de que la ruta sea correcta

class TecnicoScreen extends StatefulWidget {
  const TecnicoScreen({super.key});

  @override
  State<TecnicoScreen> createState() => _TecnicoScreenState();
}

class _TecnicoScreenState extends State<TecnicoScreen> {
  final ApiService api = ApiService();
  List<dynamic> _ordenes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrdenes();
  }

  // Obtener órdenes desde el servidor
  void _fetchOrdenes() async {
    setState(() => _isLoading = true);
    try {
      // Usamos el método de tu ApiService
      final data = await api.getOrdenesTecnico();
      setState(() {
        _ordenes = data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar órdenes: $e");
      setState(() => _isLoading = false);
    }
  }

  // Finalizar servicio y enviar notificación automática al cliente
  void _finalizarYNotificar(Map orden) async {
    try {
      // 1. Actualizar estado en la base de datos
      await api.cambiarEstado(orden['id'], 'Finalizado');

      // 2. Enviar notificación push al cliente de la orden
      // Nota: El endpoint '/api/notificar-cliente' debe estar en tu server.js
      await api.post('/api/notificar-cliente', {
        'cliente_id': orden['usuario_id'],
        'titulo': '¡Tu vehículo está listo!',
        'cuerpo':
            'El técnico ha finalizado el servicio de tu unidad en Zajo Motors.',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Servicio finalizado y cliente notificado"),
        ),
      );

      _fetchOrdenes(); // Refrescar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al procesar la solicitud")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Técnico 🛠️"),
        backgroundColor: const Color(0xFF0F2027),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrdenes),
        ],
      ),
      // 🔥 AQUÍ INTEGRAMOS TU MENÚ LATERAL
      drawer: const AppDrawer(),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ordenes.isEmpty
          ? const Center(child: Text("No tienes órdenes pendientes"))
          : RefreshIndicator(
              onRefresh: () async => _fetchOrdenes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: _ordenes.length,
                itemBuilder: (context, index) {
                  final orden = _ordenes[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(15),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey[100],
                        child: const Icon(
                          Icons.build,
                          color: Color(0xFF2C5364),
                        ),
                      ),
                      title: Text(
                        "Orden #${orden['id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Cliente ID: ${orden['usuario_id']}"),
                          Text("Estado: ${orden['estado']}"),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _finalizarYNotificar(orden),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("LISTO"),
                      ),
                    ),
                  );
                },
              ),
            ),

      // Botón flotante opcional para ir rápido a la notificación manual
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/notificar_servicio'),
        backgroundColor: Colors.orange[800],
        child: const Icon(Icons.notification_add, color: Colors.white),
      ),
    );
  }
}
