import 'dart:convert';
import '../models/prestamo.dart';
import '../models/resumen.dart';
import 'api_client.dart';

class PrestamoService {
  final ApiClient apiClient;

  PrestamoService({required this.apiClient});

  Future<List<Prestamo>> listar({String? query}) async {
    final path = (query != null && query.trim().isNotEmpty)
        ? '/prestamos?q=${Uri.encodeQueryComponent(query.trim())}'
        : '/prestamos';

    final response = await apiClient.get(path);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((item) => Prestamo.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al listar préstamos'),
    );
  }

  Future<Resumen> resumen() async {
    final response = await apiClient.get('/prestamos/resumen');
    if (response.statusCode == 200) {
      return Resumen.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al obtener resumen'),
    );
  }

  Future<Prestamo> crear(Prestamo prestamo) async {
    final response = await apiClient.post('/prestamos', prestamo.toJson());
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Prestamo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al registrar préstamo'),
    );
  }

  Future<Prestamo> actualizar(Prestamo prestamo) async {
    final response = await apiClient.put(
      '/prestamos/${prestamo.id}',
      prestamo.toJson(),
    );
    if (response.statusCode == 200) {
      return Prestamo.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al actualizar préstamo'),
    );
  }

  Future<Prestamo> marcarPagado(Prestamo prestamo) {
    return actualizar(prestamo.copyWith(pagado: true));
  }

  Future<void> eliminar(int id) async {
    final response = await apiClient.delete('/prestamos/$id');
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    throw ApiException(
      response.statusCode,
      ApiClient.extractErrorMessage(response, 'Error al anular préstamo'),
    );
  }
}
