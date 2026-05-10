import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:zajo_motors/providers/cart_provider.dart';
import '../screens/send_notification_screen.dart';

// --- TUS PANTALLAS ---
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recuperar_password_screen.dart';
import 'screens/ordenes_tecnico_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/catalogo_admin_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/compras_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/notificaciones_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/servicios_screen.dart';
import 'screens/sucursales_screen.dart';
import 'screens/tecnico_screen.dart';
import 'screens/notificar_servicio_screen.dart'; // Asegúrate de que el nombre sea correcto
import 'screens/notificaciones_servicio_screen.dart'; // 🆕 IMPORTANTE: Lista de clientes para técnico
import 'screens/usuarios_screen.dart';
import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de OneSignal
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("f61b02f0-942b-4b8c-9538-7c63d036b3ac");
  OneSignal.Notifications.requestPermission(true);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('id');
  String? rol = prefs.getString('rol'); // 🆕 Obtenemos el rol

  // Determinamos la ruta inicial basada en el rol
  String initialRoute = '/splash';
  if (userId != null) {
    if (rol == 'admin') {
      initialRoute = '/admin';
    } else if (rol == 'tecnico') {
      initialRoute = '/tecnico';
    } else {
      initialRoute = '/catalogo'; // 🎯 Cliente va directo a Catálogo
    }
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zajo Motors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        // Configuración para que las gráficas luzcan mejor
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/recuperar_password': (context) => const RecuperarPasswordScreen(),
        '/wrapper': (context) => const Wrapper(),
        '/perfil': (context) => const PerfilScreen(),
        '/historial': (context) => const HistorialScreen(),
        '/compras': (context) => const ComprasScreen(),
        '/send_notification': (context) => SendNotificationScreen(),
        '/notificaciones': (context) => const NotificacionesScreen(),
        '/servicios': (context) => const ServiciosScreen(),
        '/catalogo': (context) => const CatalogoScreen(),
        '/carrito': (context) => const CarritoScreen(),
        '/sucursales': (context) => const SucursalesScreen(),

        // 📊 ADMINISTRADOR (Gráficas)
        '/admin': (context) => const AdminScreen(),
        '/catalogo_admin': (context) => const CatalogoAdminScreen(),
        '/usuarios': (context) => const UsuariosScreen(),

        // 🛠️ TÉCNICO
        '/tecnico': (context) => const TecnicoScreen(),
        '/ordenes_tecnico': (context) => const OrdenesTecnicoScreen(),

        // 🆕 NUEVAS RUTAS PARA NOTIFICACIONES SEGMENTADAS
        '/notificaciones_servicio': (context) =>
            const NotificacionesServicioScreen(), // Lista de clientes
        '/notificar_servicio': (context) =>
            const NotificarServicioScreen(), // Formulario manual
      },
    );
  }
}
