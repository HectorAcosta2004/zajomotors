import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panel Admin")),
      body: const Center(
        child: Text("Bienvenido ADMIN 👑", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
