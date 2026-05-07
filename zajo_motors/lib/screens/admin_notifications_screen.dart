import 'package:flutter/material.dart';
import '../services/api_service.dart';
//import 'package:intl/intl.dart'; // Opcional: para dar formato a la fecha

class AdminNotificationsScreen extends StatefulWidget {
  @override
  _AdminNotificationsScreenState createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() async {
    try {
      final response = await _apiService.get('/api/historial-notificaciones');

      // CAMBIO AQUÍ: Tu API devuelve la lista en 'data', no en 'notifications'
      if (response['success'] == true) {
        setState(() {
          _notifications = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error cargando notificaciones: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Notificaciones"),
        backgroundColor: Colors.orange, // Color temático de Zajo Motors
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text("No hay notificaciones enviadas"))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];

                // Extraer textos de forma segura (Mapas de OneSignal)
                final String titulo =
                    notif['headings']?['en'] ??
                    notif['headings']?['es'] ??
                    'Sin título';
                final String contenido =
                    notif['contents']?['en'] ??
                    notif['contents']?['es'] ??
                    'Sin contenido';
                final int exitos = notif['successful'] ?? 0;

                // Formatear la fecha (queued_at viene en segundos)
                final DateTime fechaUnix = DateTime.fromMillisecondsSinceEpoch(
                  (notif['queued_at'] ?? 0) * 1000,
                );

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: const Icon(
                        Icons.notifications_active,
                        color: Colors.orange,
                      ),
                    ),
                    title: Text(
                      titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contenido),
                        const SizedBox(height: 4),
                        Text(
                          "Enviado: ${fechaUnix.day}/${fechaUnix.month} ${fechaUnix.hour}:${fechaUnix.minute}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        Text(
                          "$exitos",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
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
