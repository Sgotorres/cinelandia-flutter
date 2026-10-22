// lib/presentation/mesero/widgets/resumen_estado_mesas.dart
import '../../../domain/entities/mesa.dart';

class ResumenEstadoMesas {
  final int disponibles;
  final int pendientes;
  final int horno;
  final int lista;
  final int comiendo;
  final Map<int, Map<String, dynamic>> pedidoPorMesa;

  const ResumenEstadoMesas({
    required this.disponibles,
    required this.pendientes,
    required this.horno,
    required this.lista,
    required this.comiendo,
    required this.pedidoPorMesa,
  });

  /// Cruza las mesas con los pedidos activos en una sola pasada
  factory ResumenEstadoMesas.calcular({
    required List<Mesa> mesasActivas,
    required List<Map<String, dynamic>> pedidosActivos,
  }) {
    int disp = 0, pend = 0, hor = 0, lis = 0, com = 0;
    final Map<int, Map<String, dynamic>> mapaPedidos = {};

    for (final mesa in mesasActivas) {
      final pedido = pedidosActivos
          .where((p) => p['mesa_id'] == mesa.id)
          .firstOrNull;

      if (pedido != null) {
        mapaPedidos[mesa.id] = pedido;
      }

      final estado =
          pedido?['estado']?.toString().toLowerCase() ?? 'disponible';

      switch (estado) {
        case 'pendiente':
          pend++;
          break;
        case 'horno':
          hor++;
          break;
        case 'lista':
          lis++;
          break;
        case 'comiendo':
          com++;
          break;
        default:
          disp++;
          break;
      }
    }

    return ResumenEstadoMesas(
      disponibles: disp,
      pendientes: pend,
      horno: hor,
      lista: lis,
      comiendo: com,
      pedidoPorMesa: mapaPedidos,
    );
  }
}
