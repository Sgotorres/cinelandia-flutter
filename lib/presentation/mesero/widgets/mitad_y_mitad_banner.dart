import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/pedidos_provider.dart';

class MitadYMitadBanner extends StatelessWidget {
  const MitadYMitadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidosProvider = context.watch<PedidosProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade300 : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (pedidosProvider.modoMitadYMitad)
              BoxShadow(
                color: Colors.orange.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade100 : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pie_chart_outline,
                color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade700 : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo Mitad y Mitad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: pedidosProvider.modoMitadYMitad ? Colors.orange.shade900 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedidosProvider.modoMitadYMitad
                        ? (pedidosProvider.primeraMitad == null
                            ? 'Toca la 1ra mitad...'
                            : '1/2 ${pedidosProvider.primeraMitad!.nombre}. Toca la 2da...')
                        : 'Combina dos pizzas en una',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: pedidosProvider.modoMitadYMitad && pedidosProvider.primeraMitad != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: pedidosProvider.modoMitadYMitad
                          ? (pedidosProvider.primeraMitad == null ? Colors.orange.shade700 : Colors.indigo)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: pedidosProvider.modoMitadYMitad,
              activeColor: Colors.white,
              activeTrackColor: Colors.orange,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
              onChanged: (val) => pedidosProvider.toggleModoMitad(val),
            ),
          ],
        ),
      ),
    );
  }
}