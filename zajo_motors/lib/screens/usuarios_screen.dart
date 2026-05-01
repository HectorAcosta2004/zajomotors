import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final ApiService api = ApiService();
  List usuarios = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  // Obtener la lista de usuarios desde la API
  void cargarUsuarios() async {
    setState(() => loading = true);
    final data = await api.getUsuarios();
    setState(() {
      usuarios = data;
      loading = false;
    });
  }

  // Diálogo para editar Nombre, Email y Rol
  void _mostrarDialogoEdicion(Map user) {
    TextEditingController nombreCtrl = TextEditingController(
      text: user['nombre'],
    );
    TextEditingController emailCtrl = TextEditingController(
      text: user['email'],
    );
    String rolSeleccionado = user['rol'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Perfil"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombre Completo"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Correo Electrónico",
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: rolSeleccionado,
                items: ["cliente", "tecnico", "admin"]
                    .map(
                      (rol) => DropdownMenuItem(
                        value: rol,
                        child: Text(rol.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => rolSeleccionado = val!,
                decoration: const InputDecoration(
                  labelText: "Rol del Usuario",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = await api.editarUsuario(
                user['id'],
                nombreCtrl.text,
                emailCtrl.text,
                rolSeleccionado,
              );
              if (ok) {
                Navigator.pop(context);
                cargarUsuarios();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Usuario actualizado correctamente"),
                  ),
                );
              }
            },
            child: const Text("Guardar Cambios"),
          ),
        ],
      ),
    );
  }

  // Diálogo para cambiar la contraseña
  void _mostrarDialogoPassword(Map user) {
    TextEditingController passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Nueva clave para ${user['nombre']}"),
        content: TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Escribe la nueva contraseña",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              if (passCtrl.text.isNotEmpty) {
                bool ok = await api.cambiarPasswordAdmin(
                  user['id'],
                  passCtrl.text,
                );
                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Contraseña actualizada con éxito"),
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Actualizar Clave",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmación para eliminar
  void _confirmarEliminacion(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: const Text(
          "Esta acción eliminará al usuario permanentemente de la base de datos.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              bool ok = await api.eliminarUsuario(id);
              if (ok) {
                Navigator.pop(context);
                cargarUsuarios();
              }
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : usuarios.isEmpty
          ? const Center(child: Text("No hay usuarios registrados."))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Colors.redAccent),
                    ),
                    title: Text(
                      u['nombre'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${u['email']}\nRol: ${u['rol'].toString().toUpperCase()}",
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de Contraseña (Llave)
                        IconButton(
                          icon: const Icon(Icons.vpn_key, color: Colors.orange),
                          onPressed: () => _mostrarDialogoPassword(u),
                          tooltip: "Cambiar Contraseña",
                        ),
                        // Botón de Editar
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoEdicion(u),
                          tooltip: "Editar Perfil",
                        ),
                        // Botón de Eliminar
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmarEliminacion(u['id']),
                          tooltip: "Eliminar Usuario",
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
