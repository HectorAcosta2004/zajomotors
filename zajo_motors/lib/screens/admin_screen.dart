import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiService api = ApiService();
  String filtroTiempo = "Semana";
  bool isLoading = true;

  // Variables para almacenar los datos reales
  Map<String, dynamic> stats = {
    "ventasTotales": 0.0,
    "serviciosContados": 0,
    "productoEstrella": "Cargando...",
    "spots": <FlSpot>[], // Lista de puntos reales para la gráfica de líneas
  };

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  void _cargarEstadisticas() async {
    setState(() => isLoading = true);
    try {
      final res = await api.getEstadisticasAdmin(filtroTiempo);

      if (res != null && res['success'] == true) {
        final resumen = res['resumen'] ?? {};
        final List puntos = res['puntosGrafica'] ?? [];

        setState(() {
          stats = {
            // Usamos double.tryParse para evitar que la app truene si el valor es nulo o texto
            "ventasTotales":
                double.tryParse(resumen['totalVentas']?.toString() ?? '0.0') ??
                0.0,
            "serviciosContados":
                int.tryParse(resumen['totalServicios']?.toString() ?? '0') ?? 0,
            "productoEstrella": resumen['productoEstrella'] ?? "N/A",
            "spots": puntos.asMap().entries.map((e) {
              final monto =
                  double.tryParse(e.value['monto']?.toString() ?? '0.0') ?? 0.0;
              return FlSpot(e.key.toDouble(), monto);
            }).toList(),
          };
          isLoading = false; // Importante: Aquí se quita el círculo de carga
        });
      } else {
        print("La API respondió success: false");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("ERROR CRÍTICO EN ADMIN_SCREEN: $e");
      setState(
        () => isLoading = false,
      ); // Si hay error, también debemos quitar el cargando
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Panel Administrativo"),
        backgroundColor: const Color(0xFF0F2027),
        actions: [
          DropdownButton<String>(
            value: filtroTiempo,
            dropdownColor: const Color(0xFF2C5364),
            style: const TextStyle(color: Colors.white),
            underline: Container(), // Quita la línea de abajo
            items: ["Semana", "Mes", "Año"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => filtroTiempo = val);
                _cargarEstadisticas();
              }
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _cargarEstadisticas(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _buildBuscadorGlobal(), // Añadido el buscador arriba
                    const SizedBox(height: 20),
                    _buildHeaderStats(),
                    const SizedBox(height: 20),
                    _buildSalesChart(),
                    const SizedBox(height: 20),
                    _buildTopProductsChart(),
                    const SizedBox(height: 20),
                    _buildServicesPieChart(),
                  ],
                ),
              ),
            ),
    );
  }

  // Buscador Global
  Widget _buildBuscadorGlobal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: "Buscar por producto, cliente o ID...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF2C5364)),
        ),
        onChanged: (value) {
          // Lógica de búsqueda
        },
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Row(
      children: [
        _statCard(
          "Ventas ($filtroTiempo)",
          "\$${stats['ventasTotales'].toStringAsFixed(2)}",
          Icons.monetization_on,
          Colors.green,
        ),
        const SizedBox(width: 10),
        _statCard(
          "Servicios",
          "${stats['serviciosContados']}",
          Icons.build,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              val,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // Gráfico de Líneas con DATOS REALES
  Widget _buildSalesChart() {
    List<FlSpot> spots = stats['spots'];
    return _chartContainer(
      "Ingresos Reales ($filtroTiempo)",
      spots.isEmpty
          ? const Center(child: Text("No hay datos suficientes"))
          : LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue.shade700,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTopProductsChart() {
    return _chartContainer(
      "Producto Estrella: ${stats['productoEstrella']}",
      BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 10, color: Colors.orange, width: 20),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 18, color: Colors.orange, width: 20),
              ],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 12, color: Colors.orange, width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesPieChart() {
    return _chartContainer(
      "Distribución de Trabajo",
      PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 45,
              color: Colors.redAccent,
              title: "Mecánica",
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            PieChartSectionData(
              value: 25,
              color: Colors.blueAccent,
              title: "Eléctrico",
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.greenAccent,
              title: "Detallado",
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartContainer(String title, Widget chart) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(child: chart),
        ],
      ),
    );
  }
}
