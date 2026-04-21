import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final AuthService auth = AuthService();

  void loginUser() async {
    final user = await auth.login(email.text, password.text);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error en login")));
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
            Text("ZAJO MOTORS LOGIN", style: TextStyle(fontSize: 24)),

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

            ElevatedButton(onPressed: loginUser, child: Text("Iniciar sesión")),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text("Crear cuenta"),
            ),
          ],
        ),
      ),
    );
  }
}
