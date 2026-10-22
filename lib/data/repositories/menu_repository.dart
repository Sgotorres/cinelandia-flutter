// lib/data/repositories/menu_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../models/producto_model.dart';

class MenuRepository {
  final SupabaseClient _supabase;

  MenuRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  Stream<List<ProductoModel>> obtenerMenuStream() {
    return _supabase
        .from('productos')
        .stream(primaryKey: ['id'])
        .order('categoria', ascending: true)
        .map(
          (listaDatos) =>
              listaDatos.map((item) => ProductoModel.fromJson(item)).toList(),
        );
  }

  Future<Result<bool, Failure>> guardarProducto({
    int? id,
    required Map<String, dynamic> datos,
  }) async {
    try {
      if (id != null) {
        await _supabase.from('productos').update(datos).eq('id', id);
      } else {
        await _supabase.from('productos').insert(datos);
      }
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(ServerFailure('Error en base de datos: ${e.message}'));
    } catch (e) {
      return Error(ServerFailure('Error al guardar producto: $e'));
    }
  }

  Future<Result<bool, Failure>> eliminarProducto(int id) async {
    try {
      await _supabase.from('productos').delete().eq('id', id);
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(ServerFailure('Error en base de datos: ${e.message}'));
    } catch (_) {
      return const Error(
        ServerFailure('Ocurrió un error inesperado al eliminar.'),
      );
    }
  }

  Future<Result<bool, Failure>> actualizarDisponibilidad(
    int id,
    bool disponible,
  ) async {
    try {
      await _supabase
          .from('productos')
          .update({'disponible': disponible})
          .eq('id', id);
      return const Success(true);
    } catch (_) {
      return const Error(ServerFailure('Error al actualizar disponibilidad.'));
    }
  }
}
