// lib/presentation/admin/widgets/header_historial_caja.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HeaderHistorialCaja extends StatelessWidget {
  const HeaderHistorialCaja({super.key});

  Future<void> _limpiarHistorial(BuildContext context) async {
    // 1. Mostrar diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Limpiar historial de caja?'),
        content: const Text(
          'Esto eliminará permanentemente todos los tickets cobrados de la base de datos. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, limpiar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // 2. Si el usuario confirma, procedemos a borrar
    if (confirmar == true) {
      try {
        final supabase = Supabase.instance.client;

        // A. Obtenemos los IDs de los pedidos pagados
        final pedidosPagados = await supabase
            .from('pedidos')
            .select('id')
            .eq('estado', 'pagado');

        if (pedidosPagados.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La caja ya está vacía')),
            );
          }
          return;
        }

        // Extraemos solo la lista de números (IDs)
        final ids = pedidosPagados.map((p) => p['id'] as int).toList();

        // B. Borramos primero los detalles para evitar errores de llave foránea
        await supabase
            .from('detalles_pedido')
            .delete()
            .inFilter('pedido_id', ids);

        // C. Luego borramos los pedidos
        await supabase.from('pedidos').delete().inFilter('id', ids);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Caja limpiada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al limpiar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Historial de tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Nuevo botón para limpiar la caja
          TextButton.icon(
            onPressed: () => _limpiarHistorial(context),
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            label: const Text(
              'Limpiar Caja',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
