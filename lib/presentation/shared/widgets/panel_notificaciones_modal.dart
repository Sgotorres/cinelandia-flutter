// lib/presentation/shared/widgets/panel_notificaciones_modal.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notificaciones_provider.dart';

class PanelNotificacionesModal extends StatefulWidget {
  final String miRol;
  final String miNombre;

  const PanelNotificacionesModal({
    super.key,
    required this.miRol,
    required this.miNombre,
  });

  @override
  State<PanelNotificacionesModal> createState() =>
      _PanelNotificacionesModalState();
}

class _PanelNotificacionesModalState extends State<PanelNotificacionesModal> {
  bool _enviando = false;

  Future<void> _accionTimbrar() async {
    if (_enviando) return;
    setState(() => _enviando = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<NotificacionesProvider>();
    final esAdmin = widget.miRol.trim().toLowerCase() == 'admin';

    try {
      await provider.enviarTimbre(widget.miRol, widget.miNombre);
      if (mounted) navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            esAdmin
                ? '🔔 ¡Timbre enviado a los Meseros!'
                : '🔔 ¡Timbre enviado a Administración!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _enviando = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notiProvider = context.watch<NotificacionesProvider>();
    final notificaciones = notiProvider.notificaciones;
    final esAdmin = widget.miRol.trim().toLowerCase() == 'admin';

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Llamadas Activas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: notificaciones.isEmpty
                ? const Center(
                    child: Text('No tienes llamadas pendientes', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: notificaciones.length,
                    itemBuilder: (context, index) {
                      final noti = notificaciones[index];
                      return Card(
                        color: Colors.orange.shade50,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.orange.shade200),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active, color: Colors.orange),
                          title: Text(noti['mensaje']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            tooltip: 'Marcar como atendido',
                            onPressed: () => notiProvider.marcarComoLeida(noti['id'] as int),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.notifications_active, color: Colors.white),
              label: Text(
                esAdmin ? 'Timbrar a Meseros' : 'Timbrar a Administración',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              onPressed: _enviando ? null : _accionTimbrar,
            ),
          ),
        ],
      ),
    );
  }
}
