import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.88.105:3000";

  // 🆕 REGISTER
  Future<Map?> register(String nombre, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "email": email,
          "password": password,
        }),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "error": "Error servidor"};
      }
    } catch (e) {
      print("ERROR REGISTER: $e");
      return {"success": false, "error": "No hay conexión con el servidor"};
    }
  }

  // 🔐 LOGIN
  Future<Map?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "error": "Error servidor"};
      }
    } catch (e) {
      print("ERROR LOGIN: $e");
      return {"success": false, "error": "No hay conexión con el servidor"};
    }
  }
}
