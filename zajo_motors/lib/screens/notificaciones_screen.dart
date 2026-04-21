import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final api = ApiService();
  List data = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("id") ?? 0;

    final res = await api.getNotificaciones(id);

    setState(() {
      data = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notificaciones 🔔")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (_, i) {
          final n = data[i];
          return ListTile(title: Text(n["mensaje"]));
        },
      ),
    );
  }
}
