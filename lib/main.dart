import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos las variables seguras desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializamos Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prueba Supabase',
      home: const TestConnectionScreen(),
    );
  }
}

class TestConnectionScreen extends StatelessWidget {
  const TestConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Conexión Supabase')),
      body: Center(
        child: FutureBuilder(
          // Hacemos una consulta simple a la tabla 'productos' de tu base de datos
          future: Supabase.instance.client.from('productos').select(),
          builder: (context, snapshot) {
            // Mientras está cargando
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            
            // Si ocurre algún error de conexión o de credenciales
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

            // Si la consulta es exitosa
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
                  Text('Se encontraron ${data.length} productos en la base de datos.'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}