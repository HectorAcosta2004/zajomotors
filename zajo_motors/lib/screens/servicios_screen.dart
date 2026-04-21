import 'package:flutter/material.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Servicios")),
      body: const Center(child: Text("Solicitar servicio o ver servicios 🔧")),
    );
  }
}
