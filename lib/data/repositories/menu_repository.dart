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

  // (Mantén tus otros métodos actualizarProducto y crearProducto aquí abajo...)
}