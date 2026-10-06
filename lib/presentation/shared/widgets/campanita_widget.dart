// lib/presentation/shared/widgets/campanita_widget.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class CampanitaWidget extends StatefulWidget {
  final Color iconColor;
  const CampanitaWidget({super.key, this.iconColor = Colors.black87});

  @override
  State<CampanitaWidget> createState() => _CampanitaWidgetState();
}

class _CampanitaWidgetState extends State<CampanitaWidget> {
  late Stream<List<Map<String, dynamic>>> _notificacionesStream;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Escucharemos las notificaciones en tiempo real usando didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final miRol = context.read<AuthProvider>().userRole;
    
    // Escuchamos solo las notificaciones dirigidas a mi rol que no han sido leídas
    _notificacionesStream = _supabase
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .eq('receptor', miRol)
        .eq('leido', false)
        .order('fecha', ascending: false);
  }

  Future<void> _enviarTimbre(String miRol, String miNombre) async {
    final receptor = miRol == 'admin' ? 'mesero' : 'admin';
    final emisorNombre = miRol == 'admin' ? 'La Administración' : 'Mesero: $miNombre';

    try {
      await _supabase.from('notificaciones').insert({
        'emisor': miRol,
        'receptor': receptor,
        'mensaje': '🔔 $emisorNombre te está llamando',
      });
      if (mounted) {
        Navigator.pop(context); // Cierra el modal tras enviar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Timbre enviado exitosamente!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error enviando timbre: $e');
    }
  }

  Future<void> _marcarComoLeida(int id) async {
    await _supabase.from('notificaciones').update({'leido': true}).eq('id', id);
  }

  void _abrirPanelNotificaciones(BuildContext context, String miRol, String miNombre) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _notificacionesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final notificaciones = snapshot.data ?? [];
                    
                    if (notificaciones.isEmpty) {
                      return const Center(
                        child: Text('No tienes llamadas pendientes', style: TextStyle(color: Colors.grey)),
                      );
                    }

                    return ListView.builder(
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
                            title: Text(noti['mensaje'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                              tooltip: 'Marcar como atendido',
                              onPressed: () => _marcarComoLeida(noti['id']),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.touch_app, color: Colors.white),
                  label: Text(
                    miRol == 'admin' ? 'Timbrar a Meseros' : 'Timbrar a Administración',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  onPressed: () => _enviarTimbre(miRol, miNombre),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final miRol = authProvider.userRole;
    final miNombre = authProvider.nombreCompleto;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _notificacionesStream,
      builder: (context, snapshot) {
        final notificaciones = snapshot.data ?? [];
        final tieneNuevas = notificaciones.isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                tieneNuevas ? Icons.notifications_active : Icons.notifications_none,
                color: widget.iconColor,
                size: 28,
              ),
              onPressed: () => _abrirPanelNotificaciones(context, miRol, miNombre),
            ),
            if (tieneNuevas)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${notificaciones.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}