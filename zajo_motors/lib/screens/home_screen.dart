import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zajo Motors"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(child: Text("Bienvenido a Zajo Motors 🚗")),
    );
  }
}
