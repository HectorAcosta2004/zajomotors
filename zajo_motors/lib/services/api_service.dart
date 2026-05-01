import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://172.16.96.181:3000";

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

  // Eliminar un producto del carrito en la base de datos
  Future<bool> eliminarDelCarrito(int usuarioId, int productoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/carrito/eliminar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario_id": usuarioId, "producto_id": productoId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error de conexión: $e");
      return false;
    }
  }

  // 👥 OBTENER TODOS LOS USUARIOS
  Future<List> getUsuarios() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/usuarios"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true ? data["usuarios"] : [];
      }
      return [];
    } catch (e) {
      print("Error al obtener usuarios: $e");
      return [];
    }
  }

  // 📝 EDITAR USUARIO
  Future<bool> editarUsuario(
    int id,
    String nombre,
    String email,
    String rol,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuario/editar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": id,
          "nombre": nombre,
          "email": email,
          "rol": rol,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🗑️ ELIMINAR USUARIO
  Future<bool> eliminarUsuario(int id) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuario/eliminar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 🔑 CAMBIAR CONTRASEÑA (ADMIN)
  Future<bool> cambiarPasswordAdmin(int id, String nuevaPassword) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/usuario/password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id, "password": nuevaPassword}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error al cambiar password: $e");
      return false;
    }
  }

  // 🛠️ OBTENER SERVICIOS
  Future<List> getServicios() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/servicios"));

      print("📡 STATUS SERVICIOS: ${response.statusCode}");
      print(
        "📡 BODY SERVICIOS: ${response.body}",
      ); // Esto nos dirá qué manda Node.js

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          return data["servicios"] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("❌ ERROR SERVICIOS: $e");
      return [];
    }
  }

  // 📍 OBTENER SUCURSALES
  Future<List> getSucursales() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/sucursales"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true ? data["sucursales"] : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ➕ CREAR SUCURSAL (ADMIN)
  Future<bool> crearSucursal(
    String nombre,
    String direccion,
    String telefono,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/sucursales/crear"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "direccion": direccion,
          "telefono": telefono,
          "imagen": "img/sucursal.jpg", // Imagen fija por ahora
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 📅 AGENDAR SERVICIO
  Future<bool> agendarServicio(
    int clienteId,
    int servicioId,
    double precio,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/servicios/agendar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cliente_id": clienteId,
          "servicio_id": servicioId,
          "precio": precio,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("ERROR AL AGENDAR: $e");
      return false;
    }
  }

  // Finalizar la compra y crear la orden
  Future<bool> finalizarCompra(int usuarioId, double total) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/carrito/finalizar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario_id": usuarioId, "total": total}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        //  ESTO NOS DIRÁ EXACTAMENTE QUÉ FALLÓ
        print("❌ ERROR DEL SERVIDOR AL FINALIZAR: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ ERROR DE CONEXIÓN: $e");
      return false;
    }
  }

  //CARRITO
  Future<bool> agregarAlCarritoDB(
    int usuarioId,
    int productoId,
    int cantidad,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/carrito/agregar'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_id": usuarioId,
          "producto_id": productoId,
          "cantidad": cantidad,
        }),
      );

      if (response.statusCode == 200) {
        print("Agregado exitosamente a MySQL");
        return true;
      } else {
        print("Error del servidor: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error de conexión: $e");
      return false;
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

  // 📦 OBTENER PRODUCTOS
  Future<List> getProductos() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/productos"));

      print("PRODUCTOS STATUS: ${response.statusCode}");
      print("PRODUCTOS BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          return data["productos"];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print("ERROR PRODUCTOS: $e");
      return [];
    }
  }

  // 🛒 OBTENER CARRITO
  Future<List> getCarrito(int usuarioId) async {
    final response = await http.get(Uri.parse("$baseUrl/carrito/$usuarioId"));

    final data = jsonDecode(response.body);
    return data["carrito"];
  }

  // ❌ ELIMINAR
  Future<void> eliminarItem(int itemId) async {
    await http.post(
      Uri.parse("$baseUrl/carrito/eliminar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"item_id": itemId}),
    );
  }

  // ➕ SUMAR
  Future<void> sumar(int itemId) async {
    await http.post(
      Uri.parse("$baseUrl/carrito/sumar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"item_id": itemId}),
    );
  }

  // ➖ RESTAR
  Future<void> restar(int itemId) async {
    await http.post(
      Uri.parse("$baseUrl/carrito/restar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"item_id": itemId}),
    );
  }

  // 💳 CHECKOUT
  Future<Map?> checkout(int usuarioId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/checkout"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"usuario_id": usuarioId}),
    );

    return jsonDecode(response.body);
  }

  // 🔔 OBTENER NOTIFICACIONES
  Future<List> getNotificaciones(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/notificaciones/$usuarioId"),
      );

      print("NOTIF STATUS: ${response.statusCode}");
      print("NOTIF BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["data"];
      } else {
        return [];
      }
    } catch (e) {
      print("ERROR NOTIFICACIONES: $e");
      return [];
    }
  }

  Future<List> getOrdenesTecnico() async {
    final response = await http.get(Uri.parse("$baseUrl/ordenes/tecnico"));

    final data = jsonDecode(response.body);
    return data["data"];
  }

  // 🔧 CAMBIAR ESTADO
  Future<void> cambiarEstado(int ordenId, String estado) async {
    await http.post(
      Uri.parse("$baseUrl/orden/estado"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"orden_id": ordenId, "estado": estado}),
    );
  }

  // 📦 HISTORIAL DE ÓRDENES
  Future<List> getOrdenes(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/ordenes/$usuarioId"));

      print("ORDENES STATUS: ${response.statusCode}");
      print("ORDENES BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["ordenes"];
      } else {
        return [];
      }
    } catch (e) {
      print("ERROR ORDENES: $e");
      return [];
    }
  }

  // 📦 HISTORIAL DE ÓRDENES
  Future<List> getHistorial(int usuarioId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/ordenes/$usuarioId"));

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["ordenes"];
      } else {
        return [];
      }
    } catch (e) {
      print("ERROR HISTORIAL: $e");
      return [];
    }
  }

  // 📄 DETALLE ORDEN
  Future<List> getDetalleOrden(int ordenId) async {
    try {
      print("🔍 BUSCANDO DETALLE PARA ORDEN: $ordenId");
      final response = await http.get(
        Uri.parse("$baseUrl/orden/detalle/$ordenId"),
      );

      print("📡 STATUS DETALLE: ${response.statusCode}");
      print("📡 BODY DETALLE: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data["detalle"];
      } else {
        print("❌ El servidor devolvió success: false");
        return [];
      }
    } catch (e) {
      print("❌ ERROR DETALLE FLUTTER: $e");
      return [];
    }
  }

  // 🛒 AGREGAR AL CARRITO
  Future<Map?> agregarCarrito(int usuarioId, int productoId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/carrito/agregar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario_id": usuarioId, "producto_id": productoId}),
      );

      print("CARRITO STATUS: ${response.statusCode}");
      print("CARRITO BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false};
      }
    } catch (e) {
      print("ERROR CARRITO: $e");
      return {"success": false};
    }
  }

  // CATALOGO ADMIN
  // ➕ CREAR
  Future<void> crearProducto(Map data) async {
    await http.post(
      Uri.parse("$baseUrl/producto/crear"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
  }

  // ✏️ EDITAR
  Future<Map?> editarProducto(Map data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/producto/editar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("📤 ENVIANDO: $data");
      print("📥 RESPUESTA: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("❌ ERROR EDIT: $e");
      return {"success": false};
    }
  }

  // ❌ ELIMINAR
  Future<void> eliminarProducto(int id) async {
    await http.post(
      Uri.parse("$baseUrl/producto/eliminar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );
  }
}
