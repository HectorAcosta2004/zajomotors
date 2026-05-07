import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final ApiService _apiService = ApiService();

  void _sendNotification() async {
    try {
      // Usamos 'title' y 'body' que son las llaves que funcionaron en Postman
      final response = await _apiService.post('/api/send-notification', {
        'title': _titleController.text,
        'body': _bodyController.text,
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("¡Notificación enviada!")));
        _titleController.clear();
        _bodyController.clear();
      } else {
        print("Error del servidor: ${response.body}");
      }
    } catch (e) {
      print("Error de red: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error de conexión: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nueva Notificación")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: "Descripción"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: Text("Enviar a todos"),
            ),
          ],
        ),
      ),
    );
  }
}
