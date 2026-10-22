import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/mesa.dart';
import '../models/mesa_model.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

class MesasRepository {
  final SupabaseClient _supabase;

  MesasRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  // Transformamos los datos crudos (JSON) en entidades puras Mesa via toEntity()
  Stream<List<Mesa>> obtenerMesasStream() {
    return _supabase
        .from('mesas')
        .stream(primaryKey: ['id'])
        .order('orden')
        .map(
          (datos) => datos.map((m) => MesaModel.fromJson(m).toEntity()).toList(),
        );
  }

  // Centralizamos el manejo de errores al eliminar
  Future<Result<bool, Failure>> eliminarMesa(int id) async {
    try {
      await _supabase.from('mesas').delete().eq('id', id);
      return const Success(true);
    } on PostgrestException catch (e) {
      return Error(ServerFailure('Error en BD: ${e.message}'));
    } catch (e) {
      return const Error(ServerFailure('Error inesperado al eliminar mesa.'));
    }
  }
}
