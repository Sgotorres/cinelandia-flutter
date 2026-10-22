// lib/presentation/shared/widgets/campanita_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notificaciones_provider.dart';
import 'panel_notificaciones_modal.dart';

class CampanitaWidget extends StatefulWidget {
  final Color iconColor;
  const CampanitaWidget({super.key, this.iconColor = Colors.black87});

  @override
  State<CampanitaWidget> createState() => _CampanitaWidgetState();
}

class _CampanitaWidgetState extends State<CampanitaWidget> {
  String _rolConfigurado = '';

  void _abrirPanel(BuildContext context, String miRol, String miNombre) {
    context.read<NotificacionesProvider>().configurarRol(miRol);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PanelNotificacionesModal(
        miRol: miRol,
        miNombre: miNombre,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notiProvider = context.watch<NotificacionesProvider>();
    final miRol = authProvider.userRole;
    final miNombre = authProvider.nombreCompleto;

    if (miRol.isNotEmpty && miRol != _rolConfigurado) {
      _rolConfigurado = miRol;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NotificacionesProvider>().configurarRol(miRol);
        }
      });
    }

    final mensajeNuevo = notiProvider.ultimoMensajeRecibido;
    if (mensajeNuevo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notiProvider.limpiarUltimoMensaje();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                mensajeNuevo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.orange.shade800,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }

    final notificaciones = notiProvider.notificaciones;
    final tieneNuevas = notificaciones.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          tooltip: 'Notificaciones y Timbre',
          icon: Icon(
            tieneNuevas
                ? Icons.notifications_active
                : Icons.notifications_none,
            color: widget.iconColor,
            size: 28,
          ),
          onPressed: () => _abrirPanel(context, miRol, miNombre),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
