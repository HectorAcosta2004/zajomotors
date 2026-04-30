import 'package:flutter/material.dart';

// Modelo del producto para el carrito
class Producto {
  final String id;
  final String nombre;
  final double precio;

  Producto({required this.id, required this.nombre, required this.precio});
}

class CartProvider with ChangeNotifier {
  // Lista privada de productos en el carrito
  final List<Producto> _items = [];

  // Getter para obtener los productos desde la UI
  List<Producto> get items => _items;

  // Agrega un producto al carrito
  void agregarAlCarrito(Producto producto) {
    _items.add(producto);
    notifyListeners(); // Notifica a los widgets para redibujar
  }

  //Elimina solo UNA unidad (la primera que encuentre)
  void eliminarDelCarrito(String id) {
    // Buscamos la posición del primer elemento que coincida con el ID
    int index = _items.indexWhere((item) => item.id == id);

    // Si el producto existe en la lista (índice diferente a -1)
    if (index != -1) {
      _items.removeAt(index); // Quitamos solo ese elemento específico
      notifyListeners(); // Actualizamos la interfaz
    }
  }

  // Vacía todo el carrito (usado al finalizar la compra)
  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }

  // Opcional: Función para calcular el total rápidamente desde el Provider
  double get total {
    return _items.fold(0.0, (sum, item) => sum + item.precio);
  }
}
