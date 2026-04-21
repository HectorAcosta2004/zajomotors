import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final ApiService api = ApiService();

  List carrito = [];
  bool loading = true;
  int usuarioId = 0;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  // 🔐 Obtener usuario
  void cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getInt("id") ?? 0;

    cargarCarrito();
  }

  // 📦 Cargar carrito
  void cargarCarrito() async {
    final data = await api.getCarrito(usuarioId);

    setState(() {
      carrito = data;
      loading = false;
    });
  }

  // 💰 Calcular total
  double calcularTotal() {
    double total = 0;

    for (var item in carrito) {
      total += double.parse(item["total"].toString());
    }

    return total;
  }

  // 💳 Checkout
  void hacerCheckout() async {
    final response = await api.checkout(usuarioId);

    if (response != null && response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compra realizada correctamente ✅")),
      );

      cargarCarrito(); // limpiar vista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response?["error"] ?? "Error en compra")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Carrito 🛒")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : carrito.isEmpty
          ? const Center(child: Text("Carrito vacío 😢"))
          : Column(
              children: [
                // 🛒 LISTA
                Expanded(
                  child: ListView.builder(
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final item = carrito[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: ListTile(
                          title: Text(
                            item["nombre"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          subtitle: Text(
                            "Cantidad: ${item["cantidad"]} | \$${item["total"]}",
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ➖ RESTAR
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () async {
                                  await api.restar(item["id"]);
                                  cargarCarrito();
                                },
                              ),

                              // ➕ SUMAR
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  await api.sumar(item["id"]);
                                  cargarCarrito();
                                },
                              ),

                              // ❌ ELIMINAR
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await api.eliminarItem(item["id"]);
                                  cargarCarrito();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 💰 TOTAL + BOTÓN
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Total: \$${calcularTotal()}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: hacerCheckout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                          ),
                          child: const Text(
                            "Finalizar compra 💳",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
