class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Error en el servidor de Supabase']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Sin conexión a internet']);
}