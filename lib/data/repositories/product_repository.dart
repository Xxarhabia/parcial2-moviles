import 'package:dio/dio.dart';
import 'package:segundo_parcial/core/constants/app_constants.dart';
import 'package:segundo_parcial/data/models/product_model.dart';

class ProductRepository {
  late final Dio _dio;

  ProductRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.mockApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Interceptor para loggin
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('DIO: $obj'),
      ),
    );
  }

  // Obtener todos los productos
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(AppConstants.productsEndpoint);
      final List data = response.data as List;
      return data.map((json) => ProductModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Crear producto
  Future<ProductModel> createProduct(ProductModel prorduct) async {
    try {
      final response = await _dio.post(
        AppConstants.productsEndpoint,
        data: prorduct.toMap(),
      );
      return ProductModel.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Eliminar producto
  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('${AppConstants.productsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Obtener producto por ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      return ProductModel.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de conexion agotado. Verifica tu internet');
      case DioExceptionType.connectionError:
        return Exception('Sin conexion a internet');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 404) return Exception('Recurso no encontrado');
        if (status == 500) return Exception('Error del servidor');
        return Exception('Error HTTP $status');
      default:
        return Exception('Error inesperado: ${e.message}');
    }
  }
}