// lib/data/services/digital_receipt_service.dart
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/recibo.dart';
import '../../domain/services/receipt_service.dart';

class DigitalReceiptService implements ReceiptService {
  final SupabaseClient _supabase;
  static const String _bucketName = 'recibos';

  DigitalReceiptService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Result<ReciboGenerado, Failure>> generarRecibo(
    Recibo recibo, {
    Duration expiracion = const Duration(minutes: 45),
  }) async {
    try {
      final expiraEn = DateTime.now().add(expiracion);
      final pdfBytes = await _construirPdf(recibo, expiraEn);

      String? signedUrl;
      try {
        final fileName =
            'ticket_${recibo.pedidoId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        await _supabase.storage
            .from(_bucketName)
            .uploadBinary(
              fileName,
              pdfBytes,
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: true,
              ),
            );
        signedUrl = await _supabase.storage
            .from(_bucketName)
            .createSignedUrl(fileName, expiracion.inSeconds);
      } catch (_) {
        // Si el bucket no existe aún o no hay red, usamos el payload estructurado en el QR como respaldo.
        signedUrl = null;
      }

      final qrPayload = signedUrl ?? _construirPayloadLocal(recibo, expiraEn);

      return Success(
        ReciboGenerado(
          recibo: recibo,
          qrPayload: qrPayload,
          signedUrl: signedUrl,
          expiraEn: expiraEn,
        ),
      );
    } catch (e) {
      return Error(ServerFailure('Error al generar el recibo digital: $e'));
    }
  }

  String _construirPayloadLocal(Recibo recibo, DateTime expiraEn) {
    final df = DateFormat('dd/MM/yyyy HH:mm');
    final buffer = StringBuffer();
    buffer.writeln('🍕 PIZZA PLANETA - RECIBO DIGITAL');
    buffer.writeln('Ticket #${recibo.pedidoId} | ${recibo.mesaNombre}');
    buffer.writeln('Fecha: ${df.format(recibo.fecha)}');
    buffer.writeln('--------------------------------');
    for (final item in recibo.items) {
      final tallaStr =
          (item.talla != 'Única' && item.talla != 'null' && item.talla.isNotEmpty)
              ? ' (${item.talla})'
              : '';
      buffer.writeln(
        '${item.cantidad}x ${item.nombre}$tallaStr - \$${item.subtotal.toStringAsFixed(2)}',
      );
      if (item.nota != null && item.nota!.trim().isNotEmpty) {
        buffer.writeln('   Nota: ${item.nota}');
      }
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('TOTAL: \$${recibo.total.toStringAsFixed(2)}');
    buffer.writeln('Válido hasta: ${df.format(expiraEn)}');
    return buffer.toString();
  }

  Future<Uint8List> _construirPdf(Recibo recibo, DateTime expiraEn) async {
    final pdf = pw.Document();
    final df = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'PIZZA PLANETA',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Recibo Digital - Ticket #${recibo.pedidoId}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Mesa: ${recibo.mesaNombre}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Fecha: ${df.format(recibo.fecha)}', style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(),
              ...recibo.items.map((item) {
                final tallaStr = (item.talla != 'Única' && item.talla != 'null')
                    ? ' (${item.talla})'
                    : '';
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              '${item.cantidad}x ${item.nombre}$tallaStr',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      if (item.nota != null && item.nota!.trim().isNotEmpty)
                        pw.Text(
                          '  Nota: ${item.nota}',
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                    ],
                  ),
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '\$${recibo.total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Enlace válido hasta: ${df.format(expiraEn)}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '¡Gracias por su visita!',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
