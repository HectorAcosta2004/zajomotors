import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetalleOrdenScreen extends StatefulWidget {
  final int ordenId;
  const DetalleOrdenScreen({super.key, required this.ordenId});

  @override
  State<DetalleOrdenScreen> createState() => _DetalleOrdenScreenState();
}

class _DetalleOrdenScreenState extends State<DetalleOrdenScreen> {
  final api = ApiService();
  List detalle = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    final response = await api.getDetalleOrden(widget.ordenId);

    setState(() {
      detalle = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle Orden")),
      body: ListView.builder(
        itemCount: detalle.length,
        itemBuilder: (context, i) {
          final d = detalle[i];

          return ListTile(
            title: Text(d["nombre"]),
            subtitle: Text("Cantidad: ${d["cantidad"]}"),
            trailing: Text("\$${d["precio"]}"),
          );
        },
      ),
    );
  }
}
