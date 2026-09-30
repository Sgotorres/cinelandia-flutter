// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart'; 
import 'presentation/mesero/screens/mesero_home_screen.dart'; // Añadida la importación de la pantalla del mesero
import 'data/repositories/pedidos_repository.dart';
import 'domain/usecases/calcular_precio_item_usecase.dart';
import 'domain/usecases/gestionar_carrito_usecase.dart';
import 'domain/usecases/tomar_pedido_usecase.dart';
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
        ChangeNotifierProvider(create: (_) => MenuProvider()..cargarMenu()),
        
        ChangeNotifierProvider(create: (_) {
          // 1. Instanciar la capa de datos (Repositorio)
          final pedidosRepository = PedidosRepository();
          
          // 2. Instanciar los casos de uso inyectando sus respectivas dependencias
          final tomarPedidoUseCase = TomarPedidoUseCase(pedidosRepository);
          
          final calcularPrecioUseCase = CalcularPrecioItemUseCase();
          final gestionarCarritoUseCase = GestionarCarritoUseCase(calcularPrecioUseCase);
          
          // 3. Retornar el Provider inyectándole los casos de uso ya construidos
          return PedidosProvider(tomarPedidoUseCase, gestionarCarritoUseCase);
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Planeta', // Actualizado el nombre de la app
      home: MeseroHomeScreen(), // Cambiado para que inicie directamente en la vista del mesero
    );
  } 
}