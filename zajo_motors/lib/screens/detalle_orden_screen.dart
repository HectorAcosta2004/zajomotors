import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetalleOrdenScreen extends StatefulWidget {
  final int ordenId;
  const DetalleOrdenScreen({super.key, required this.ordenId});

  @override
  State<DetalleOrdenScreen> createState() => _DetalleOrdenScreenState();
}

class _DetalleOrdenScreenState extends State<DetalleOrdenScreen> {
  final ApiService api = ApiService();
  List detalles = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
  }

  void cargarDetalle() async {
    final data = await api.getDetalleOrden(widget.ordenId);
    setState(() {
      detalles = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos el total de forma segura convirtiendo a double cada item
    double totalAcumulado = detalles.fold(0.0, (sum, item) {
      double precio = double.tryParse(item["precio"].toString()) ?? 0.0;
      int cantidad = int.tryParse(item["cantidad"].toString()) ?? 1;
      return sum + (precio * cantidad);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Orden #${widget.ordenId}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : detalles.isEmpty
          ? const Center(
              child: Text("No se encontraron detalles para esta orden."),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Resumen de la Orden",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: detalles.length,
                    itemBuilder: (context, index) {
                      final d = detalles[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.build_circle,
                          color: Colors.blue,
                        ),
                        title: Text(d["nombre"] ?? "Sin nombre"),
                        subtitle: Text("Cantidad: ${d["cantidad"]}"),
                        trailing: Text(
                          "\$${d["precio"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL PAGADO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "\$${totalAcumulado.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
