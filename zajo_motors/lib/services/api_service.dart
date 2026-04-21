import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.1.25:3000"; // 👈 CAMBIA TU IP

  // 🔐 LOGIN
  Future<Map<String, dynamic>?> loginWithUID(String uid) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid}),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print("Error login API: $e");
      return null;
    }
  }

  // 🆕 REGISTER
  Future<Map<String, dynamic>?> registerUser(Map data) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      return jsonDecode(res.body);
    } catch (e) {
      print("Error register API: $e");
      return null;
    }
  }
}
