// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart';
import 'providers/auth_provider.dart'; // <-- 1. Importamos AuthProvider

// Router
import 'core/routes/app_router.dart'; // <-- 2. Importamos el AppRouter

// Capas de Dominio y Datos
import 'data/repositories/pedidos_repository.dart';
import 'domain/usecases/calcular_precio_item_usecase.dart';
import 'domain/usecases/gestionar_carrito_usecase.dart';
import 'domain/usecases/tomar_pedido_usecase.dart';

import 'providers/mesas_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga de variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicialización de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        // 3. Inyectamos AuthProvider para que el router y el login funcionen
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()..escucharMenu()),
        ChangeNotifierProvider(create: (_) => MesasProvider()..cargarMesas()),
        
        ChangeNotifierProvider(
          create: (_) {
            final pedidosRepository = PedidosRepository();
            final tomarPedidoUseCase = TomarPedidoUseCase(pedidosRepository);
            final calcularPrecioUseCase = CalcularPrecioItemUseCase();
            final gestionarCarritoUseCase = GestionarCarritoUseCase(
              calcularPrecioUseCase,
            );

            return PedidosProvider(tomarPedidoUseCase, gestionarCarritoUseCase);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Cambiamos MaterialApp por MaterialApp.router
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Planeta',
      // 5. Asignamos la configuración de go_router
      routerConfig: AppRouter.router(context),
    );
  }
}
