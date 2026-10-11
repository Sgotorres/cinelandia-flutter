// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DataSources
import '../../data/datasources/local_pedidos_datasource.dart';
import '../../data/datasources/remote_pedidos_datasource.dart';

// Repositorios
import '../../data/repositories/pedidos_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/mesas_repository.dart';
import '../../data/repositories/usuarios_repository.dart';
import '../../data/repositories/notificaciones_repository.dart';

// Casos de Uso
import '../../domain/usecases/calcular_precio_item_usecase.dart';
import '../../domain/usecases/gestionar_carrito_usecase.dart';
import '../../domain/usecases/tomar_pedido_usecase.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/mesas_provider.dart';
import '../../providers/pedidos_provider.dart';
import '../../providers/usuarios_provider.dart';
import '../../providers/notificaciones_provider.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. Clientes Externos (registrado UNA sola vez)
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. DataSources
  sl.registerLazySingleton(() => RemotePedidosDataSource(supabaseClient: sl()));
  sl.registerLazySingleton(() => LocalPedidosDataSource());

  // 3. Repositorios
  sl.registerLazySingleton(() => MenuRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => MesasRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => UsuariosRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => NotificacionesRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => PedidosRepository(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // 4. Casos de Uso
  sl.registerLazySingleton(() => CalcularPrecioItemUseCase());
  sl.registerLazySingleton(() => GestionarCarritoUseCase(sl()));
  sl.registerLazySingleton(() => TomarPedidoUseCase(sl()));

  // 5. Providers
  sl.registerFactory(() => AuthProvider());
  sl.registerFactory(() => MenuProvider(menuRepository: sl()));
  sl.registerFactory(() => MesasProvider(mesasRepository: sl()));
  sl.registerFactory(() => PedidosProvider(sl(), sl(), sl()));
  sl.registerFactory(() => UsuariosProvider(usuariosRepository: sl()));
  sl.registerFactory(() => NotificacionesProvider(sl()));
}