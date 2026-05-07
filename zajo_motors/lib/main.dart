import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// --- IMPORTANTE: DECISIÓN DE NOTIFICACIONES ---
// Si usas OneSignal, mantén esto:
import 'package:onesignal_flutter/onesignal_flutter.dart';
// Si decides cambiar a Firebase (FCM), borra OneSignal y usa:
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

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
import 'screens/usuarios_screen.dart';
import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- CONFIGURACIÓN DE NOTIFICACIONES ---
  // Opción 1: Si quieres usar OneSignal (lo que tienes ahora)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("f61b02f0-942b-4b8c-9538-7c63d036b3ac");
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  print("OneSignal Player ID: ${OneSignal.User.pushSubscription.id}");
  print("¿Está suscrito?: ${OneSignal.User.pushSubscription.optedIn}");
  OneSignal.Notifications.requestPermission(true);

  // Opción 2: Si quieres usar Firebase (FCM) para coincidir con tu servidor
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance.subscribeToTopic('noticias');

  // Carga de sesión
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MyApp(initialRoute: userId != null ? '/home' : '/splash'),
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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
        '/admin': (context) => const AdminScreen(),
        '/catalogo_admin': (context) => const CatalogoAdminScreen(),
        '/usuarios': (context) => const UsuariosScreen(),
        '/tecnico': (context) => const TecnicoScreen(),
        '/ordenes_tecnico': (context) => const OrdenesTecnicoScreen(),
      },
    );
  }
}
