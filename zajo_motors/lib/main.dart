import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:zajo_motors/providers/cart_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalogo_admin_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/servicios_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/usuarios_screen.dart';
import 'screens/sucursales_screen.dart';
import 'screens/compras_screen.dart';
import 'screens/historial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Aquí está la corrección (runApp en lugar de runApprunApp)
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("id") != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Zajo Motors",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),

      routes: {
        "/login": (context) => const LoginScreen(),
        "/home": (context) => const HomeScreen(),

        "/catalogo": (context) => const CatalogoScreen(),
        "/catalogo_admin": (context) => const CatalogoAdminScreen(),
        "/carrito": (context) => const CarritoScreen(),
        "/servicios": (context) => const ServiciosScreen(),

        "/notificaciones": (context) => const NotificacionesScreen(),
        "/perfil": (context) => const PerfilScreen(),

        "/usuarios": (context) => const UsuariosScreen(),
        "/sucursales": (context) => const SucursalesScreen(),
        "/compras": (context) => const ComprasScreen(),
        "/historial": (context) => const HistorialScreen(),
      },

      home: const SplashScreen(),
    );
  }
}
