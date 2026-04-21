import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://172.16.97.125:3000";

  Future<Map<String, dynamic>?> loginWithUID(String uid) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("Error API: $e");
      return null;
    }
  }
}