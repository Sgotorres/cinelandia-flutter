// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DataSources y Servicios
import '../../data/datasources/local_pedidos_datasource.dart';
import '../../data/datasources/remote_pedidos_datasource.dart';
import '../../data/services/digital_receipt_service.dart';
import '../../domain/services/receipt_service.dart';

// Repositorios
import '../../data/repositories/pedidos_repository.dart';
import '../../data/repositories/menu_repository.dart';
import '../../data/repositories/mesas_repository.dart';
import '../../data/repositories/usuarios_repository.dart';
import '../../data/repositories/notificaciones_repository.dart';

// Casos de Uso
import '../../domain/usecases/calcular_precio_item_usecase.dart';
import '../../domain/usecases/generar_recibo_usecase.dart';
import '../../domain/usecases/gestionar_carrito_usecase.dart';
import '../../domain/usecases/tomar_pedido_usecase.dart';

// Providers
import '../../presentation/auth/providers/auth_provider.dart';
import '../../presentation/admin/providers/usuarios_provider.dart';
import '../../presentation/mesero/providers/pedidos_provider.dart';
import '../../presentation/shared/providers/menu_provider.dart';
import '../../presentation/shared/providers/mesas_provider.dart';
import '../../presentation/shared/providers/notificaciones_provider.dart';
import '../utils/sound_service.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. Clientes Externos (registrado UNA sola vez)
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // 2. DataSources y Servicios
  sl.registerLazySingleton(() => RemotePedidosDataSource(supabaseClient: sl()));
  sl.registerLazySingleton(() => LocalPedidosDataSource());
  sl.registerLazySingleton(() => SoundService());
  sl.registerLazySingleton<ReceiptService>(
    () => DigitalReceiptService(supabaseClient: sl()),
  );

  // 3. Repositorios
  sl.registerLazySingleton(() => MenuRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => MesasRepository(supabaseClient: sl()));
  sl.registerLazySingleton(() => UsuariosRepository(supabaseClient: sl()));
  sl.registerLazySingleton(
    () => NotificacionesRepository(supabaseClient: sl()),
  );
  sl.registerLazySingleton(
    () => PedidosRepository(remoteDataSource: sl(), localDataSource: sl()),
  );

  // 4. Casos de Uso
  sl.registerLazySingleton(() => CalcularPrecioItemUseCase());
  sl.registerLazySingleton(() => GestionarCarritoUseCase(sl()));
  sl.registerLazySingleton(() => TomarPedidoUseCase(sl()));
  sl.registerLazySingleton(() => GenerarReciboUseCase(sl()));

  // 5. Providers
  sl.registerFactory(() => AuthProvider());
  sl.registerFactory(() => MenuProvider(menuRepository: sl()));
  sl.registerFactory(() => MesasProvider(mesasRepository: sl()));
  sl.registerFactory(() => PedidosProvider(sl(), sl(), sl()));
  sl.registerFactory(() => UsuariosProvider(usuariosRepository: sl()));
  sl.registerFactory(() => NotificacionesProvider(sl(), sl()));
}
