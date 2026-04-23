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

  List detalle = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarDetalle();
  }

  void cargarDetalle() async {
    final data = await api.getDetalleOrden(widget.ordenId);

    setState(() {
      detalle = data;
      loading = false;
    });
  }

  double calcularTotal() {
    double total = 0;

    for (var item in detalle) {
      total +=
          double.parse(item["precio"].toString()) *
          int.parse(item["cantidad"].toString());
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle Orden #${widget.ordenId}")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: detalle.length,
                    itemBuilder: (context, index) {
                      final item = detalle[index];

                      return ListTile(
                        title: Text(item["nombre"]),
                        subtitle: Text(
                          "Cantidad: ${item["cantidad"]} | \$${item["precio"]}",
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Total: \$${calcularTotal()}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
