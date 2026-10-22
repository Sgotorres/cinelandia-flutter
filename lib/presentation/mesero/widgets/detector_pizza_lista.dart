// lib/presentation/mesero/widgets/detector_pizza_lista.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/mesa.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/sound_service.dart';

class DetectorPizzaLista {
  final Map<int, String> _estadosPrevios = {};
  bool _esCargaInicial = true;

  /// Evalúa los pedidos activos y dispara el sonido + SnackBar si alguno pasó a 'lista'.
  void verificar(
    BuildContext context, {
    required List<Map<String, dynamic>> pedidosActivos,
    required List<Mesa> mesasActivas,
  }) {
    if (_esCargaInicial) {
      for (final p in pedidosActivos) {
        final id = p['id'] as int;
        _estadosPrevios[id] =
            p['estado']?.toString().toLowerCase() ?? 'pendiente';
      }
      _esCargaInicial = false;
      return;
    }

    String? mesaRecienLista;

    for (final p in pedidosActivos) {
      final id = p['id'] as int;
      final estadoActual = p['estado']?.toString().toLowerCase() ?? 'pendiente';
      final estadoAnterior = _estadosPrevios[id];

      if (estadoAnterior != null &&
          estadoAnterior != 'lista' &&
          estadoActual == 'lista') {
        final mesaId = p['mesa_id'] as int?;
        mesaRecienLista = mesasActivas
            .where((m) => m.id == mesaId)
            .map((m) => m.nombre)
            .firstOrNull;
      }

      _estadosPrevios[id] = estadoActual;
    }

    final idsActivos = pedidosActivos.map((p) => p['id'] as int).toSet();
    _estadosPrevios.removeWhere((id, _) => !idsActivos.contains(id));

    if (mesaRecienLista != null) {
      di.sl<SoundService>().tocarCampanita();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🔔 ¡El pedido de $mesaRecienLista está LISTO para entregar!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }
}
