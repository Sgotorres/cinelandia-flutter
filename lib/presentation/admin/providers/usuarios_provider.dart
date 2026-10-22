// lib/presentation/admin/providers/usuarios_provider.dart
import 'package:flutter/material.dart';

import '../../../domain/entities/usuario.dart';
import '../../../data/repositories/usuarios_repository.dart';
import '../../../core/utils/result.dart';

class UsuariosProvider extends ChangeNotifier {
  final UsuariosRepository _usuariosRepository;

  UsuariosProvider({required UsuariosRepository usuariosRepository})
    : _usuariosRepository = usuariosRepository;

  Stream<List<Usuario>> get usuariosStream =>
      _usuariosRepository.obtenerUsuariosStream();

  Future<String?> eliminarUsuario(int id) async {
    final result = await _usuariosRepository.eliminarUsuario(id);
    if (result is Error) {
      return (result as Error).failure.message;
    }
    return null; // Éxito
  }
}
