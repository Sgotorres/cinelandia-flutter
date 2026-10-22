// lib/presentation/mesero/widgets/modal_recibo_qr.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/di/injection.dart' as di;
import '../../../core/utils/result.dart';
import '../../../domain/entities/recibo.dart';
import '../../../domain/usecases/generar_recibo_usecase.dart';
import '../../shared/providers/menu_provider.dart';
import '../providers/pedidos_provider.dart';

class ModalReciboQr extends StatefulWidget {
  final int pedidoId;
  final String mesaNombre;

  const ModalReciboQr({
    super.key,
    required this.pedidoId,
    required this.mesaNombre,
  });

  @override
  State<ModalReciboQr> createState() => _ModalReciboQrState();
}

class _ModalReciboQrState extends State<ModalReciboQr> {
  ReciboGenerado? _reciboGenerado;
  String? _errorMsg;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _prepararRecibo();
  }

  Future<void> _prepararRecibo() async {
    try {
      final pedidosProvider = context.read<PedidosProvider>();
      final menuProvider = context.read<MenuProvider>();

      final detallesRaw = await pedidosProvider
          .detallesPedidoStream(widget.pedidoId)
          .first;

      if (detallesRaw.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMsg = 'El pedido no tiene productos registrados.';
            _cargando = false;
          });
        }
        return;
      }

      double totalCalculado = 0.0;
      final List<ReciboItem> items = [];

      for (final item in detallesRaw) {
        final int cantidad = item['cantidad'] ?? 1;
        final double precioUnitario =
            (item['precio_unitario'] as num).toDouble();
        final String talla = item['talla'] ?? 'Única';
        final String? nota = item['nota'];
        final double precioExtra = item['precio_extra'] != null
            ? (item['precio_extra'] as num).toDouble()
            : 0.0;

        String nombreP1 = 'Producto ${item['producto_id']}';
        try {
          nombreP1 = menuProvider.productos
              .firstWhere((p) => p.id == item['producto_id'])
              .nombre;
        } catch (_) {}

        String? nombreP2;
        if (item['producto_2_id'] != null) {
          try {
            nombreP2 = menuProvider.productos
                .firstWhere((p) => p.id == item['producto_2_id'])
                .nombre;
          } catch (_) {}
        }

        final nombreFinal =
            nombreP2 != null ? '1/2 $nombreP1 y 1/2 $nombreP2' : nombreP1;

        final reciboItem = ReciboItem(
          nombre: nombreFinal,
          cantidad: cantidad,
          talla: talla,
          precioUnitario: precioUnitario,
          precioExtra: precioExtra,
          nota: nota,
        );
        totalCalculado += reciboItem.subtotal;
        items.add(reciboItem);
      }

      final recibo = Recibo(
        pedidoId: widget.pedidoId,
        mesaNombre: widget.mesaNombre,
        fecha: DateTime.now(),
        items: items,
        total: totalCalculado,
      );

      final useCase = di.sl<GenerarReciboUseCase>();
      final resultado = await useCase.execute(recibo: recibo);

      if (!mounted) return;

      switch (resultado) {
        case Success(:final value):
          setState(() {
            _reciboGenerado = value;
            _cargando = false;
          });
        case Error(:final failure):
          setState(() {
            _errorMsg = failure.message;
            _cargando = false;
          });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = 'Error al generar el recibo: $e';
          _cargando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _cargando
              ? const SizedBox(
                  height: 240,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.indigo),
                        SizedBox(height: 16),
                        Text('Generando recibo digital y código QR...'),
                      ],
                    ),
                  ),
                )
              : _errorMsg != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMsg!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pizza Planeta',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  Text(
                                    'Ticket #${_reciboGenerado!.recibo.pedidoId} • ${_reciboGenerado!.recibo.mesaNombre}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                QrImageView(
                                  data: _reciboGenerado!.qrPayload,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  backgroundColor: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _reciboGenerado!.signedUrl != null
                                          ? Icons.cloud_done_outlined
                                          : Icons.qr_code_scanner,
                                      size: 16,
                                      color: Colors.indigo,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _reciboGenerado!.signedUrl != null
                                            ? 'Escanea para descargar PDF (expira ${DateFormat('HH:mm').format(_reciboGenerado!.expiraEn)})'
                                            : 'Escanea para ver el detalle del ticket en tu teléfono',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Detalle de consumo (${df.format(_reciboGenerado!.recibo.fecha)}):',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._reciboGenerado!.recibo.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.cantidad}x ${item.nombre}${item.talla != 'Única' && item.talla != 'null' ? ' (${item.talla})' : ''}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    '\$${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL A PAGAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$${_reciboGenerado!.recibo.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
