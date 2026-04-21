import 'package:flutter/material.dart';

class TecnicoScreen extends StatelessWidget {
  const TecnicoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panel Técnico")),
      body: const Center(
        child: Text("Bienvenido Técnico 🛠️", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
