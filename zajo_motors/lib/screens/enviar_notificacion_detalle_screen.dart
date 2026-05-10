import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EnviarNotificacionDetalleScreen extends StatefulWidget {
  final String clienteId;
  final String clienteNombre;
  final String servicioNombre;

  const EnviarNotificacionDetalleScreen({
    super.key,
    required this.clienteId,
    required this.clienteNombre,
    required this.servicioNombre,
  });

  @override
  State<EnviarNotificacionDetalleScreen> createState() =>
      _EnviarNotificacionDetalleScreenState();
}

class _EnviarNotificacionDetalleScreenState
    extends State<EnviarNotificacionDetalleScreen> {
  final ApiService api = ApiService();
  final TextEditingController _mensajeController = TextEditingController();
  bool _isSending = false;

  void _enviar() async {
    if (_mensajeController.text.isEmpty) return;

    setState(() => _isSending = true);

    final response = await api.post('/api/notificar-cliente', {
      'cliente_id': widget.clienteId,
      'titulo': 'Aviso: ${widget.servicioNombre}',
      'cuerpo': _mensajeController.text.trim(),
    });

    setState(() => _isSending = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notificación enviada correctamente")),
      );
      Navigator.pop(context); // Regresa a la lista
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificar a ${widget.clienteNombre}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enviando actualización para: ${widget.servicioNombre}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mensajeController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Escribe el mensaje para el cliente...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSending ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  _isSending ? "Enviando..." : "Enviar Notificación Push",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
