import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrdenesTecnicoScreen extends StatefulWidget {
  const OrdenesTecnicoScreen({super.key});

  @override
  State<OrdenesTecnicoScreen> createState() => _OrdenesTecnicoScreenState();
}

class _OrdenesTecnicoScreenState extends State<OrdenesTecnicoScreen> {
  final ApiService api = ApiService();

  List ordenes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarOrdenes();
  }

  void cargarOrdenes() async {
    final data = await api.getOrdenesTecnico(); // 👈 asegúrate tener esto

    setState(() {
      ordenes = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Órdenes Técnico 👨‍🔧")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: ordenes.length,
              itemBuilder: (context, index) {
                final orden = ordenes[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Orden #${orden["id"]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text("Estado: ${orden["estado"]}"),
                        Text("Total: \$${orden["total"]}"),

                        const SizedBox(height: 10),

                        // 🔥 AQUI VAN LOS BOTONES
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await api.cambiarEstado(
                                  orden["id"],
                                  "en_proceso",
                                );
                                cargarOrdenes();
                              },
                              child: const Text("Iniciar"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              onPressed: () async {
                                await api.cambiarEstado(
                                  orden["id"],
                                  "terminado",
                                );
                                cargarOrdenes();
                              },
                              child: const Text("Finalizar"),
                            ),
                          ],
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
