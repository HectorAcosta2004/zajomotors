import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificarServicioScreen extends StatefulWidget {
  final String? clienteId;
  final String? clienteNombre;
  final String? servicioNombre;

  // Constructor que recibe los datos
  const NotificarServicioScreen({
    super.key,
    this.clienteId,
    this.clienteNombre,
    this.servicioNombre,
  });

  @override
  State<NotificarServicioScreen> createState() =>
      _NotificarServicioScreenState();
}

class _NotificarServicioScreenState extends State<NotificarServicioScreen> {
  final ApiService api = ApiService();
  final TextEditingController _mensajeController = TextEditingController();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enviar Avance")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TARJETA DE INFORMACIÓN RECIBIDA
            Card(
              color: Colors.blueGrey[50],
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // USAMOS widget.nombre para mostrar lo que recibimos
                    Text(
                      "Cliente: ${widget.clienteNombre ?? 'Sin Nombre'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Servicio: ${widget.servicioNombre ?? 'Sin Servicio'}",
                    ),
                    Text(
                      "ID: ${widget.clienteId ?? 'Sin ID'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mensajeController,
              decoration: const InputDecoration(
                labelText: "Mensaje de avance",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSending ? null : _enviar,
              child: Text(_isSending ? "Enviando..." : "Enviar Notificación"),
            ),
          ],
        ),
      ),
    );
  }

  void _enviar() async {
    // Lógica de envío usando widget.clienteId
  }
}
