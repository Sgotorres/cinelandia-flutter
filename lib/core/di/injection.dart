// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repositorios
import '../../data/repositories/pedidos_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/mesas_repository.dart'; // <-- NUEVO

// Casos de Uso
import '../../domain/usecases/calcular_precio_item_usecase.dart';
import '../../domain/usecases/gestionar_carrito_usecase.dart';
import '../../domain/usecases/tomar_pedido_usecase.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/mesas_provider.dart';
import '../../providers/pedidos_provider.dart';

import '../../data/repositories/usuarios_repository.dart';
import '../../providers/usuarios_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. Clientes Externos
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. Repositorios
  sl.registerLazySingleton(() => PedidosRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => MenuRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => UsuariosRepository(supabaseClient: sl()));
  sl.registerLazySingleton(
    () => MesasRepository(supabaseClient: sl()),
  ); // <-- NUEVO

  // 3. Casos de Uso
  sl.registerLazySingleton(() => CalcularPrecioItemUseCase());
  sl.registerLazySingleton(() => GestionarCarritoUseCase(sl()));
  sl.registerLazySingleton(() => TomarPedidoUseCase(sl()));

  // 4. Providers
  sl.registerFactory(() => AuthProvider());
  sl.registerFactory(() => MenuProvider(menuRepository: sl()));

  // <-- CORRECCIÓN: Le inyectamos su repositorio automáticamente con sl()
  sl.registerFactory(() => MesasProvider(mesasRepository: sl()));

  sl.registerFactory(() => PedidosProvider(sl(), sl(), sl()));

  sl.registerFactory(() => UsuariosProvider(usuariosRepository: sl()));
}
