import 'package:flutter/material.dart';

class TecnicoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel del Técnico'),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildTaskItem(
            'Mantenimiento Preventivo',
            'Toyota Hilux - Placa ABC-123',
            'Pendiente',
          ),
          _buildTaskItem(
            'Cambio de Aceite',
            'Nissan Frontier - Placa XYZ-789',
            'En Proceso',
          ),
          _buildTaskItem(
            'Revisión de Frenos',
            'Ford Ranger - Placa LMN-456',
            'Completado',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        tooltip: 'Nueva Tarea',
      ),
    );
  }

  Widget _buildTaskItem(String title, String subtitle, String status) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.build, color: Colors.orange),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Pendiente'
                ? Colors.red.shade100
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Pendiente' ? Colors.red : Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
