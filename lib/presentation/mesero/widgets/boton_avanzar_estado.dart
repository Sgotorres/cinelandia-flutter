import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/pedidos_provider.dart';

class BotonAvanzarEstado extends StatelessWidget {
  final int pedidoId;

  const BotonAvanzarEstado({super.key, required this.pedidoId});

  Future<void> _avanzarEstado(BuildContext context, String estadoActual) async {
    String nuevoEstado;
    switch (estadoActual.toLowerCase()) {
      case 'pendiente':
        nuevoEstado = 'horno';
        break;
      case 'horno':
        nuevoEstado = 'lista';
        break;
      case 'lista':
        nuevoEstado = 'comiendo';
        break;
      case 'comiendo':
        nuevoEstado = 'pagado';
        break;
      default:
        return;
    }

    final provider = context.read<PedidosProvider>();
    final error = await provider.actualizarEstado(pedidoId, nuevoEstado);

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else if (nuevoEstado == 'pagado' && context.mounted) {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  Widget _buildBotonAccion(BuildContext context, String estadoActual) {
    String texto = '';
    IconData icono = Icons.help;
    Color color = Colors.grey;

    switch (estadoActual.toLowerCase()) {
      case 'pendiente':
        texto = 'Meter al Horno';
        icono = Icons.local_fire_department;
        color = Colors.orange;
        break;
      case 'horno':
        texto = 'Marcar como Lista';
        icono = Icons.soup_kitchen;
        color = Colors.blue;
        break;
      case 'lista':
        texto = 'Entregar en Mesa';
        icono = Icons.room_service;
        color = Colors.greenAccent.shade700;
        break;
      case 'comiendo':
        texto = 'Cobrar y Liberar';
        icono = Icons.payments;
        color = Colors.purple;
        break;
      case 'pagado':
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: Icon(icono, size: 24),
        label: Text(
          texto,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: () => _avanzarEstado(context, estadoActual),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.read<PedidosProvider>();

    return StreamBuilder<String>(
      stream: pedidosProvider.estadoPedidoStream(pedidoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return _buildBotonAccion(context, snapshot.data!);
      },
    );
  }
}
