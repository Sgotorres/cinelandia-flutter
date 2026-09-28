// lib/presentation/mesero/widgets/producto_tile.dart
import 'package:flutter/material.dart';
import '../../../data/models/producto_model.dart';

class ProductoTile extends StatelessWidget {
  final ProductoModel producto;
  final VoidCallback onTap;

  const ProductoTile({
    super.key, 
    required this.producto, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final precioBase = producto.precio ?? producto.precioG ?? 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🍕', style: TextStyle(fontSize: 40)), // Emoji dinámico a futuro
              const SizedBox(height: 8),
              Text(
                producto.nombre, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Desde \$${precioBase.toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.indigo, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}