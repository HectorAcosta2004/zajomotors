import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final AuthService auth = AuthService();

  void registerUser() async {
    final user = await auth.register(email.text, password.text);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("REGISTRO ZAJO MOTORS"),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 20),

            ElevatedButton(onPressed: registerUser, child: Text("Registrarse")),
          ],
        ),
      ),
    );
  }
}
