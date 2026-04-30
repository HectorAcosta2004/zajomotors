import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ApiService api = ApiService();

  List productos = [];
  bool loading = true;
  String origen = "cliente";

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

                              // 🔥 BOTÓN AGREGAR CONEXIÓN A BASE DE DATOS
                              if (origen != "admin")
                                ElevatedButton(
                                  onPressed: () async {
                                    // 1. Obtenemos el ID del usuario activo
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final usuarioId = prefs.getInt("id") ?? 0;

                                    if (usuarioId == 0) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Error: Debes iniciar sesión primero',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    // 2. Enviamos la petición al servidor (MySQL)
                                    bool exito = await api.agregarAlCarritoDB(
                                      usuarioId,
                                      int.parse(p["id"].toString()),
                                      1, // Cantidad agregada por defecto
                                    );

                                    if (exito) {
                                      // 3. Opcional: Agregar al provider para uso rápido en UI
                                      final nuevoProducto = Producto(
                                        id: p["id"].toString(),
                                        nombre: p["nombre"],
                                        precio: double.parse(
                                          p["precio"].toString(),
                                        ),
                                      );

                                      Provider.of<CartProvider>(
                                        context,
                                        listen: false,
                                      ).agregarAlCarrito(nuevoProducto);

                                      // 4. Feedback visual de éxito
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${p["nombre"]} agregado al carrito',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    } else {
                                      // 5. Feedback visual de error en servidor
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Error al guardar en la base de datos',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text("Agregar"),
                                ),

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
