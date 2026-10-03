// lib/data/repositories/menu_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/result.dart';
import '../models/producto_model.dart';

class MenuRepository {
  final SupabaseClient _supabase;

  // Inyectamos el cliente de Supabase
  MenuRepository({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient ?? Supabase.instance.client;

// NUEVO MÉTODO CON STREAM
  Stream<List<ProductoModel>> obtenerMenuStream() {
    return _supabase
        .from('productos')
        .stream(primaryKey: ['id'])
        .order('categoria', ascending: true) // Ordenamos por categoría para mejor UI
        .map((listaDatos) => listaDatos
            .map((item) => ProductoModel.fromJson(item))
            .toList());
  }

  // Puedes conservar tu método obtenerMenu() si aún lo necesitas 
  // para otra lógica (ej. una carga estática inicial), 
  // o puedes eliminarlo si todo migrará a Streams.
  Future<Result<List<ProductoModel>, Failure>> obtenerMenu() async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .order('id', ascending: true);
          
      final List<Map<String, dynamic>> datosReales =
          List<Map<String, dynamic>>.from(response);
          
      final productos = datosReales.map((item) => ProductoModel.fromJson(item)).toList();
      return Success(productos);
    } on PostgrestException catch (e) {
      return Error(ServerFailure('Error en base de datos: ${e.message}'));
    } catch (e) {
      return Error(const ServerFailure('Ocurrió un error inesperado al cargar el menú'));
    }
  }
}