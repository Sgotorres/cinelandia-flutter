import 'package:cinelandia/providers/notificaciones_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Router
import 'core/routes/app_router.dart';

// Inyección de Dependencias
import 'core/di/injection.dart' as di;

// Providers (Ya no importamos el repositorio aquí)
import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/mesas_provider.dart';
import 'providers/usuarios_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicialización de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Inicializar el contenedor de dependencias (GetIt)
  await di.init();

  runApp(
    MultiProvider(
      providers: [
        // Proveemos las dependencias inyectadas desde nuestro contenedor
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<MenuProvider>()..escucharMenu(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<MesasProvider>()..cargarMesas(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<PedidosProvider>()),
        ChangeNotifierProvider(
          create: (_) => di.sl<UsuariosProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<NotificacionesProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ELIMINADO: Ya no inyectamos el repositorio aquí manualmente

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de internet globalmente
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint('Internet restaurado. Sincronizando comandas pendientes...');
        
        // NUEVO: Delegamos la orden de sincronizar al Provider (que contiene la lógica de negocio)
        // usando el contexto de la aplicación, ya que MyApp es hijo de MultiProvider.
        if (mounted) {
          context.read<PedidosProvider>().sincronizarPedidosOffline();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Planeta', // O Pizzeria Panzerotto según tu preferencia
      routerConfig: AppRouter.router(context),
    );
  }
}