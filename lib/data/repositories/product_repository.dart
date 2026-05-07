import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../../core/constants/app_constants.dart';

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

    // Interceptor de autenticación
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final userJson = prefs.getString(AppConstants.currentUserKey);
          if (userJson != null) {
            options.headers['X-User-Session'] = 'authenticated';
            options.headers['X-App-Token'] = AppConstants.appToken;
          }
          print('🔐 AUTH INTERCEPTOR — Headers: ${options.headers}');
          return handler.next(options);
        },
        onError: (error, handler) {
          print('❌ DIO ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    // Interceptor de logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 DIO: $obj'),
      ),
    );
  }

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(AppConstants.productsEndpoint);
      final List data = response.data as List;
      return data.map((json) => ProductModel.fromMap(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _dio.post(
        AppConstants.productsEndpoint,
        data: product.toMap(),
      );
      return ProductModel.fromMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _dio.delete('${AppConstants.productsEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Tiempo de conexión agotado.');
      case DioExceptionType.connectionError:
        return Exception('Sin conexión a internet.');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 404) return Exception('Recurso no encontrado.');
        if (status == 500) return Exception('Error del servidor.');
        return Exception('Error HTTP $status');
      default:
        return Exception('Error inesperado: ${e.message}');
    }
  }
}