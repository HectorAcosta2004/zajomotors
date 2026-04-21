import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ApiService api = ApiService();

  List productos = [];
  bool loading = true;
  int usuarioId = 0;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    cargarProductos();
  }

  // 🔐 OBTENER USUARIO LOGUEADO
  void cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getInt("id") ?? 0;
    });
  }

  // 📦 CARGAR PRODUCTOS
  void cargarProductos() async {
    final data = await api.getProductos();

    setState(() {
      productos = data;
      loading = false;
    });
  }

  // 🛒 AGREGAR AL CARRITO
  void agregarAlCarrito(int productoId) async {
    final response = await api.agregarCarrito(usuarioId, productoId);

    if (response != null && response["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto agregado al carrito 🛒")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al agregar producto ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Catálogo 🛒")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : productos.isEmpty
          ? const Center(child: Text("No hay productos"))
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    leading: p["imagen"] != null
                        ? Image.network(
                            p["imagen"],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image),
                          )
                        : const Icon(Icons.shopping_bag),

                    title: Text(
                      p["nombre"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Text(p["descripcion"] ?? ""),

                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "\$${p["precio"]}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () => agregarAlCarrito(p["id"]),
                          child: const Text("Agregar"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
