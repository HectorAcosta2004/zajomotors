import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Zajo Motors 🚗",
      body: const Center(
        child: Text("Bienvenido 👋", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

Widget card(BuildContext context, String title, IconData icon, String route) {
  return GestureDetector(
    onTap: () => Navigator.pushNamed(context, route),

    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
        ),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
