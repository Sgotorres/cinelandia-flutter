// lib/presentation/mesero/widgets/mesas_grid.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/mesa.dart';
import 'mesa_card.dart';

class MesasGrid extends StatelessWidget {
  final List<Mesa> mesasActivas;
  final Map<int, Map<String, dynamic>> pedidoPorMesa;

  const MesasGrid({
    super.key,
    required this.mesasActivas,
    required this.pedidoPorMesa,
  });

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final columnas = ancho >= 900 ? 4 : (ancho >= 600 ? 3 : 2);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: mesasActivas.length,
      itemBuilder: (context, i) {
        final mesa = mesasActivas[i];
        return MesaCard(
          mesaId: mesa.id,
          mesaNombre: mesa.nombre,
          pedidoActivo: pedidoPorMesa[mesa.id],
        );
      },
    );
  }
}
