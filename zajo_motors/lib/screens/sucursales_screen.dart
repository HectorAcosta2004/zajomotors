import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  final ApiService api = ApiService();
  List sucursales = [];
  bool loading = true;
  String rol = "cliente";

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = await api.getSucursales();
    setState(() {
      sucursales = data;
      rol = prefs.getString("rol") ?? "cliente";
      loading = false;
    });
  }

  void _mostrarDialogoAgregar() {
    TextEditingController nombreCtrl = TextEditingController();
    TextEditingController direccionCtrl = TextEditingController();
    TextEditingController telCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Sucursal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre de la tienda",
              ),
            ),
            TextField(
              controller: direccionCtrl,
              decoration: const InputDecoration(
                labelText: "Dirección completa",
              ),
            ),
            TextField(
              controller: telCtrl,
              decoration: const InputDecoration(
                labelText: "Teléfono de contacto",
              ),
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
              if (nombreCtrl.text.isNotEmpty && direccionCtrl.text.isNotEmpty) {
                bool ok = await api.crearSucursal(
                  nombreCtrl.text,
                  direccionCtrl.text,
                  telCtrl.text,
                );
                if (ok) {
                  Navigator.pop(context);
                  cargarDatos();
                }
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuestras Sucursales"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : sucursales.isEmpty
          ? const Center(child: Text("Próximamente más sucursales..."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: sucursales.length,
              itemBuilder: (context, index) {
                final s = sucursales[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 40,
                        ),
                        title: Text(
                          s["nombre"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(s["direccion"]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              s["telefono"] ?? "Sin teléfono",
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      // Solo el Admin ve el botón para agregar
      floatingActionButton: rol == "admin"
          ? FloatingActionButton(
              onPressed: _mostrarDialogoAgregar,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
