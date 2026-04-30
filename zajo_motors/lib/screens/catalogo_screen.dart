import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
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

  String origen = "cliente"; // 🔥 default

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args != null && args is Map) {
      origen = args["from"] ?? "cliente";
    }
  }

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  void cargarProductos() async {
    final data = await api.getProductos();

    setState(() {
      productos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: origen == "admin" ? "Catálogo (Admin)" : "Catálogo",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: productos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final p = productos[index];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 🖼️ Imagen
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              "${api.baseUrl}/${p["imagen"]}",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 50),
                            ),
                          ),
                        ),

                        // 📦 INFO
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                p["nombre"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text("\$${p["precio"]}"),
                              const SizedBox(height: 10),

                              // 🔥 SOLO CLIENTE VE BOTÓN
                              if (origen != "admin")
                                ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Agregar"),
                                ),

                              // 👑 ADMIN VE BOTÓN EDITAR
                              if (origen == "admin")
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  onPressed: () {},
                                  child: const Text("Editar"),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
