// lib/data/repositories/pedidos_repository.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../datasources/local_pedidos_datasource.dart';
import '../datasources/remote_pedidos_datasource.dart';
import '../models/pedido_detalle_model.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/result.dart';

class PedidosRepository {
  final RemotePedidosDataSource _remoteDataSource;
  final LocalPedidosDataSource _localDataSource;

  PedidosRepository({
    required RemotePedidosDataSource remoteDataSource,
    required LocalPedidosDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  Future<Result<int, Failure>> crearPedido(
    int mesaId,
    double totalNuevosProductos,
    List<PedidoDetalleModel> detalles, {
    int? pedidoIdExistente,
  }) async {
    final conectividad = await Connectivity().checkConnectivity();
    final sinInternet = conectividad.contains(ConnectivityResult.none);

    // Lógica Offline
    if (sinInternet && pedidoIdExistente == null) {
      await _localDataSource.guardarPedidoOffline(mesaId, totalNuevosProductos, detalles);
      return const Error(NetworkFailure('Sin internet. La comanda se guardó localmente.'));
    }

    try {
      // Llamada directa al DataSource Remoto
      final pedidoId = await _remoteDataSource.crearPedido(
        mesaId, 
        detalles, 
        pedidoIdExistente: pedidoIdExistente
      );
      return Success(pedidoId);
    } on ServerException catch (e) {
      // Fallback a modo offline si el servidor de Supabase falla
      if (pedidoIdExistente == null) {
        await _localDataSource.guardarPedidoOffline(mesaId, totalNuevosProductos, detalles);
        return const Error(NetworkFailure('Error de servidor. La comanda se guardó localmente.'));
      }
      return Error(ServerFailure(e.message));
    } catch (e) {
      return Error(ServerFailure('Fallo inesperado: $e'));
    }
  }

  Future<Result<bool, Failure>> eliminarDetalleYActualizarPedido(int detalleId, int pedidoId) async {
    try {
      await _remoteDataSource.eliminarDetalleYActualizarPedido(detalleId, pedidoId);
      return const Success(true);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    }
  }

  Future<Result<bool, Failure>> actualizarEstadoPedido(int pedidoId, String nuevoEstado) async {
    try {
      await _remoteDataSource.actualizarEstadoPedido(pedidoId, nuevoEstado);
      return const Success(true);
    } on ServerException catch (e) {
      return Error(ServerFailure(e.message));
    }
  }

  Future<void> sincronizarPedidosOffline() async {
    final pendientes = await _localDataSource.obtenerYVaciarCola();
    if (pendientes.isEmpty) return;

    for (var pedidoMap in pendientes) {
      final detallesRaw = pedidoMap['detalles'] as List<dynamic>;
      final detalles = detallesRaw.map((d) => PedidoDetalleModel.fromJson(d)).toList();
      
      await crearPedido(pedidoMap['mesa_id'], pedidoMap['total'], detalles);
    }
  }

  // --- STREAMS PASADOS DIRECTAMENTE DESDE EL DATASOURCE ---
  Stream<List<Map<String, dynamic>>> obtenerTodosLosPedidosStream() =>
      _remoteDataSource.obtenerTodosLosPedidosStream();

  Stream<List<Map<String, dynamic>>> obtenerDetallesPedidoStream(int pedidoId) =>
      _remoteDataSource.obtenerDetallesPedidoStream(pedidoId);

  Stream<String> obtenerEstadoPedidoStream(int pedidoId) =>
      _remoteDataSource.obtenerEstadoPedidoStream(pedidoId);
      
  Stream<List<Map<String, dynamic>>> obtenerPedidosActivosStream() =>
      _remoteDataSource.obtenerPedidosActivosStream();
}