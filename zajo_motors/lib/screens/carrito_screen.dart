import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../layouts/main_layout.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final ApiService api = ApiService();

  void _eliminarItem(Producto producto) async {
    // 1. Obtenemos el usuario activo
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt("id") ?? 0;

    if (usuarioId == 0) return;

    // 2. Mensaje visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Borrando de la base de datos..."),
        duration: Duration(milliseconds: 500),
      ),
    );

    // 3. Ejecutamos la API (Pasamos usuario_id y producto_id)
    bool exito = await api.eliminarDelCarrito(
      usuarioId,
      int.parse(producto.id),
    );

    if (exito) {
      // Si se borró en MySQL, lo borramos de la pantalla
      Provider.of<CartProvider>(
        context,
        listen: false,
      ).eliminarDelCarrito(producto.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Producto eliminado"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error al eliminar en la BD"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _realizarCompra() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tu carrito está vacío"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt("id") ?? 0;

    if (usuarioId == 0) return;

    double total = cart.items.fold(0, (sum, item) => sum + item.precio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generando orden en MySQL..."),
        duration: Duration(seconds: 1),
      ),
    );

    // Llamamos a la BD para finalizar
    bool exito = await api.finalizarCompra(usuarioId, total);

    if (exito) {
      cart.vaciarCarrito(); // Vaciamos la pantalla
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("¡Compra Exitosa!"),
          content: const Text("Tu orden ha sido guardada en la base de datos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error del servidor al finalizar"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return MainLayout(
      title: "Mi Carrito",
      body: cart.items.isEmpty
          ? const Center(child: Text("Tu carrito está vacío"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final p = cart.items[index];
                      return ListTile(
                        title: Text(p.nombre),
                        subtitle: Text("\$${p.precio}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarItem(p), // BOTÓN ELIMINAR
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: _realizarCompra, // BOTÓN FINALIZAR
                    child: const Text(
                      "Finalizar Compra",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
