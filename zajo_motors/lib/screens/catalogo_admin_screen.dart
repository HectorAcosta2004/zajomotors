import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';

class CatalogoAdminScreen extends StatefulWidget {
  const CatalogoAdminScreen({super.key});

  @override
  State<CatalogoAdminScreen> createState() => _CatalogoAdminScreenState();
}

class _CatalogoAdminScreenState extends State<CatalogoAdminScreen> {
  final ApiService api = ApiService();

  List productos = [];
  bool loading = true;

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

  // ===============================
  // ❌ ELIMINAR
  // ===============================
  void eliminarProducto(int id) async {
    await api.eliminarProducto(id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Producto eliminado")));

    cargarProductos();
  }

  // ===============================
  // ✏️ EDITAR
  // ===============================
  void editarProducto(Map producto) {
    final nombre = TextEditingController(text: producto["nombre"]);
    final precio = TextEditingController(text: producto["precio"].toString());
    final stock = TextEditingController(text: producto["stock"].toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar producto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombre,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio"),
              ),
              TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                // 🛑 VALIDACIONES
                if (nombre.text.isEmpty ||
                    precio.text.isEmpty ||
                    stock.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Campos vacíos")),
                  );
                  return;
                }

                final res = await api.editarProducto({
                  "id": int.parse(producto["id"].toString()),
                  "nombre": nombre.text,
                  "precio": double.tryParse(precio.text) ?? 0,
                  "stock": int.tryParse(stock.text) ?? 0,
                });
                print("RESPUESTA EDITAR: $res"); // 👈 DEBUG

                if (res?["success"] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(" ✅Producto actualizado")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Error al actualizar")),
                  );
                }

                Navigator.pop(context);
                cargarProductos();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // ===============================
  // ➕ CREAR
  // ===============================
  void agregarProducto() {
    final nombre = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Nuevo producto"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombre,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio"),
              ),
              TextField(
                controller: stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Stock"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombre.text.isEmpty ||
                    precio.text.isEmpty ||
                    stock.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Campos vacíos")),
                  );
                  return;
                }

                await api.crearProducto({
                  "nombre": nombre.text,
                  "descripcion": "",
                  "precio": double.tryParse(precio.text) ?? 0,
                  "stock": int.tryParse(stock.text) ?? 0,
                  "imagen": "default.png",
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Producto creado")),
                );

                Navigator.pop(context);
                cargarProductos();
              },
              child: const Text("Crear"),
            ),
          ],
        );
      },
    );
  }

  // ===============================
  // 🎨 UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Admin - Catálogo 👑",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: productos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
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
                              Text("\$${p["precio"]}"),
                              const SizedBox(height: 5),
                              Text(
                                "Stock: ${p["stock"]}",
                                style: TextStyle(
                                  color: p["stock"] > 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () => editarProducto(p),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => eliminarProducto(p["id"]),
                                  ),
                                ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: agregarProducto,
        child: const Icon(Icons.add),
      ),
    );
  }
}
