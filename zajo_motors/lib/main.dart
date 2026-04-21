import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔽 SCREENS
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

import 'screens/catalogo_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/servicios_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/sucursales_screen.dart';
import 'screens/compras_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 🔐 Verificar sesión
  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id") != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zajo Motors",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // 🔥 RUTAS COMPLETAS
      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),

        // CLIENTE
        "/catalogo": (context) => const CatalogoScreen(),
        "/carrito": (context) => const CarritoScreen(),
        "/servicios": (context) => const ServiciosScreen(),

        // GENERAL
        "/notificaciones": (context) => const NotificacionesScreen(),
        "/perfil": (context) => const PerfilScreen(),

        // ADMIN
        "/usuarios": (context) => const UsuariosScreen(),
        "/sucursales": (context) => const SucursalesScreen(),
        "/compras": (context) => const ComprasScreen(),
      },

      // 🔐 CONTROL DE SESIÓN AUTOMÁTICO
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (context, snapshot) {
          // ⏳ Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ✅ Usuario logueado
          if (snapshot.data == true) {
            return const HomeScreen();
          }

          // ❌ No logueado
          return const LoginScreen();
        },
      ),
    );
  }
}
