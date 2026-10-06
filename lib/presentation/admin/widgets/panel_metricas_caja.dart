// lib/presentation/admin/widgets/panel_metricas_caja.dart
import 'package:flutter/material.dart';
import 'stats_tile.dart';

class PanelMetricasCaja extends StatelessWidget {
  final double ingresosTotales;
  final int cantidadVentas;

  const PanelMetricasCaja({
    super.key,
    required this.ingresosTotales,
    required this.cantidadVentas,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          StatsTile(
            title: 'Ingresos',
            value: '\$${ingresosTotales.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          StatsTile(
            title: 'Completados',
            value: '$cantidadVentas',
            icon: Icons.receipt_long,
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }
}