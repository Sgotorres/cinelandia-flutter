// lib/presentation/mesero/widgets/leyenda_mesas.dart
import 'package:flutter/material.dart';

class LeyendaMesas extends StatelessWidget {
  final int disponibles;
  final int pendientes;
  final int horno;
  final int lista;
  final int comiendo;

  const LeyendaMesas({
    super.key,
    required this.disponibles,
    required this.pendientes,
    required this.horno,
    required this.lista,
    required this.comiendo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado de Mesas', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        const SizedBox(height: 12),
        // Hacemos la fila scrolleable por si hay pantallas muy estrechas
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Badge(texto: 'Libres', count: disponibles, color: Colors.green),
              const SizedBox(width: 8),
              _Badge(texto: 'Pendiente', count: pendientes, color: Colors.orange),
              const SizedBox(width: 8),
              _Badge(texto: 'En Horno', count: horno, color: Colors.blue),
              const SizedBox(width: 8),
              _Badge(texto: 'Listas', count: lista, color: Colors.greenAccent.shade700),
              const SizedBox(width: 8),
              _Badge(texto: 'Comiendo', count: comiendo, color: Colors.purple),
            ],
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String texto;
  final int count;
  final Color color;

  const _Badge({required this.texto, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    // Si el conteo es 0, lo ponemos gris claro para no saturar la vista
    final bool isActive = count > 0;
    final Color activeColor = isActive ? color : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto, 
            style: TextStyle(color: activeColor, fontSize: 13, fontWeight: FontWeight.bold)
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count', 
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }
}