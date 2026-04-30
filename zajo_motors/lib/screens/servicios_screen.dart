import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ApiService api = ApiService();

  List servicios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarServicios();
  }

  void cargarServicios() async {
    final data = await api.getServicios();
    setState(() {
      servicios = data;
      loading = false;
    });
  }

  void _agendar(Map servicio) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt("id") ?? 0;

    if (usuarioId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Inicia sesión primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Agendando servicio y asignando técnico..."),
        duration: Duration(seconds: 1),
      ),
    );

    // Convertimos de manera segura los datos
    int servicioId = int.parse(servicio["id"].toString());
    double precio = double.parse(servicio["precio"].toString());

    bool exito = await api.agendarServicio(usuarioId, servicioId, precio);

    if (exito) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("¡Servicio Agendado!"),
          content: Text(
            "Has agendado exitosamente: ${servicio["nombre"]}.\n\nSe ha notificado a uno de nuestros técnicos.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Genial"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al agendar el servicio"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Nuestros Servicios",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : servicios
                .isEmpty // 🔥 Validación de la pantalla en blanco
          ? const Center(
              child: Text(
                "No hay servicios disponibles en este momento.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final s = servicios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼️ Imagen del servicio
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.network(
                          "${api.baseUrl}/${s["imagen"]}",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.handyman,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // 📝 Detalles y Botón
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s["nombre"] ?? "Servicio",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              s["descripcion"] ?? "Sin descripción",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$${s["precio"]}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _agendar(s),
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Agendar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
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
    );
  }
}
