// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/menu_provider.dart';
import 'providers/pedidos_provider.dart'; // Añadido el import de pedidos

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
      title: 'Prueba Supabase',
      home: TestConnectionScreen(),
    );
  } // <- Faltaba esta llave para cerrar el build
} // <- Faltaba esta llave para cerrar la clase MyApp

class TestConnectionScreen extends StatelessWidget {
  const TestConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Conexión Supabase')),
      body: Center(
        child: FutureBuilder(
          future: Supabase.instance.client.from('productos').select(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error al conectar: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }
            final data = snapshot.data as List<dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Conexión exitosa con Supabase!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Se encontraron ${data.length} productos.'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}