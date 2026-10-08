import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Router
import 'core/routes/app_router.dart';

// Inyección de Dependencias
import 'core/di/injection.dart' as di;

// Repositorios
import 'data/repositories/pedidos_repository.dart';

// Providers
import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/mesas_provider.dart';
import 'providers/usuarios_provider.dart'; // <-- NUEVA IMPORTACIÓN

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
        ), // <-- NUEVO PROVIDER REGISTRADO
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
  // Pedimos el repositorio inyectado desde GetIt en lugar de instanciarlo manualmente
  final _pedidosRepository = di.sl<PedidosRepository>();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de internet globalmente
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!results.contains(ConnectivityResult.none)) {
        debugPrint('Internet restaurado. Sincronizando comandas pendientes...');
        _pedidosRepository.sincronizarPedidosOffline();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Planeta',
      routerConfig: AppRouter.router(context),
    );
  }
}
