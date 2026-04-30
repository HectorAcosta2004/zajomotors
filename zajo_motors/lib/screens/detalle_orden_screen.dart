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
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle Orden #${widget.ordenId}"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Resumen de productos/servicios",
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
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(d["nombre"]),
                        subtitle: Text("Cantidad: ${d["cantidad"]}"),
                        trailing: Text(
                          "\$${d["precio"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL PAGADO",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "\$${detalles.fold(0.0, (sum, item) => sum + (double.parse(item["precio"].toString()) * int.parse(item["cantidad"].toString())))}",
                        style: const TextStyle(
                          fontSize: 20,
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
