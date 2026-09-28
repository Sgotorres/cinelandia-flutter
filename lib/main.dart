// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart'; 
import 'presentation/mesero/screens/mesero_home_screen.dart'; // Añadida la importación de la pantalla del mesero

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
        // Es recomendable registrar tu PedidosProvider de una vez
        ChangeNotifierProvider(create: (_) => PedidosProvider()), 
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