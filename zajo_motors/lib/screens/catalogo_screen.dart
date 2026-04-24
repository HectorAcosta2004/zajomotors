import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final ApiService api = ApiService();

  List productos = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  void cargarProductos() async {
    final data = await api.getProductos();

    setState(() {
      productos = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: "Catálogo",
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(p["nombre"]),
                    subtitle: Text("\$${p["precio"]}"),
                  ),
                );
              },
            ),
    );
  }
}
