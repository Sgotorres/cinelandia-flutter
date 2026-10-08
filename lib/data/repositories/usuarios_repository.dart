import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/usuario_model.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';

class UsuariosRepository {
  final SupabaseClient _supabase;

  UsuariosRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  Stream<List<UsuarioModel>> obtenerUsuariosStream() {
    return _supabase
        .from('usuarios')
        .stream(primaryKey: ['id'])
        .order('nombre')
        .map((datos) => datos.map((u) => UsuarioModel.fromJson(u)).toList());
  }

  Future<Result<bool, Failure>> eliminarUsuario(int id) async {
    try {
      await _supabase.from('usuarios').delete().eq('id', id);
      return const Success(true);
    } catch (e) {
      return const Error(
        ServerFailure('Error inesperado al eliminar el usuario.'),
      );
    }
  }
}
