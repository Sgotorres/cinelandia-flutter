// lib/data/repositories/menu_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto_model.dart';

class MenuRepository {
  final _supabase = Supabase.instance.client;

  // 1. Obtener todos los productos (Pizzas, Bebidas, etc.)
  Future<List<ProductoModel>> obtenerMenu() async {
    try {
      final response = await _supabase
          .from('productos')
          .select()
          .order('id', ascending: true);

      // Convertimos explícitamente la respuesta para evitar el error de tipado
      final List<Map<String, dynamic>> datosReales = List<Map<String, dynamic>>.from(response);
             
      return datosReales.map((item) => ProductoModel.fromJson(item)).toList();
    } catch (e) {
      print("Error obteniendo el menú: $e");
      throw Exception('Error al cargar el menú');
    }
  }

  // 2. Actualizar un producto existente (Ej: cambiar precio o marcar como agotado)
  Future<void> actualizarProducto(int id, Map<String, dynamic> datosActualizados) async {
    try {
      await _supabase
          .from('productos')
          .update(datosActualizados)
          .eq('id', id);
    } catch (e) {
      print("Error actualizando el producto: $e");
      throw Exception('Error al actualizar el producto');
    }
  }

  // 3. Crear un nuevo producto (Para la pantalla de administrador)
  Future<void> crearProducto(ProductoModel producto) async {
    try {
      // Usamos el toJson() del modelo pero removemos el ID para que Supabase lo genere
      final jsonDatos = producto.toJson();
      jsonDatos.remove('id'); 

      await _supabase.from('productos').insert(jsonDatos);
    } catch (e) {
      print("Error creando el producto: $e");
      throw Exception('Error al crear el producto en la base de datos');
    }
  }
}