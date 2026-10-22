// lib/presentation/mesero/widgets/detector_pizza_lista.dart
import 'package:flutter/material.dart';
import '../../../data/models/mesa_model.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/sound_service.dart';

class DetectorPizzaLista {
  final Map<int, String> _estadosPrevios = {};
  bool _esCargaInicial = true;

  /// Evalúa los pedidos activos y dispara el sonido + SnackBar si alguno pasó a 'lista'.
  void verificar(
    BuildContext context, {
    required List<Map<String, dynamic>> pedidosActivos,
    required List<MesaModel> mesasActivas,
  }) {
    // 1. Si acaba de abrir la pantalla, solo registramos cómo están las mesas sin sonar
    if (_esCargaInicial) {
      for (final p in pedidosActivos) {
        final id = p['id'] as int;
        _estadosPrevios[id] = p['estado']?.toString().toLowerCase() ?? 'pendiente';
      }
      _esCargaInicial = false;
      return;
    }

    String? mesaRecienLista;

    // 2. Comparamos el estado anterior con el nuevo estado que llegó de Supabase
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

    // 3. Limpiamos de la memoria los pedidos que ya fueron cobrados o cancelados
    final idsActivos = pedidosActivos.map((p) => p['id'] as int).toSet();
    _estadosPrevios.removeWhere((id, _) => !idsActivos.contains(id));

    // 4. Si una pizza acaba de salir del horno a 'lista', disparamos la alerta
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