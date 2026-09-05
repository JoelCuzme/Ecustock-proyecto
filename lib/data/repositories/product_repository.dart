import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/product.dart';

class ProductRepository {
  ProductRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? sharedDioClient;

  final DioClient _dioClient;

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dioClient.client.get('/api/v1/productos');

      debugPrint('GET ${response.requestOptions.uri}');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      debugPrint('Request headers: ${response.requestOptions.headers}');

      final data = response.data;

      if (data is List) {
        return data
            .map<Product>((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (data is Map<String, dynamic> && data['products'] is List) {
        return (data['products'] as List)
            .map<Product>((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List)
            .map<Product>((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Some backends return { success: true, products: [...] }
      if (data is Map<String, dynamic> && data['productos'] is List) {
        return (data['productos'] as List)
            .map<Product>((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return const [];
    } catch (error) {
      // If DioException, print detailed info
      try {
        if (error is DioException) {
          debugPrint('DioException requesting products: ${error.requestOptions.uri}');
          debugPrint('Request headers: ${error.requestOptions.headers}');
          debugPrint('Response status: ${error.response?.statusCode}');
          debugPrint('Response data: ${error.response?.data}');
        } else {
          debugPrint('Error fetching products: $error');
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<Product> addProduct(Product product) async {
    try {
      final response = await _dioClient.client.post(
        '/api/v1/productos',
        data: product.toJson(includeId: false),
      );

      debugPrint('POST ${response.requestOptions.uri}');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      debugPrint('Request headers: ${response.requestOptions.headers}');

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('product')) {
          final productData = data['product'];
          if (productData is Map<String, dynamic>) {
            return Product.fromJson(productData);
          }
        }

        // Some APIs return { success: true, productos: [...] } or { producto: {...} }
        if (data.containsKey('producto') && data['producto'] is Map<String, dynamic>) {
          return Product.fromJson(data['producto'] as Map<String, dynamic>);
        }

        return Product.fromJson(data);
      }

      throw Exception('Respuesta inesperada al crear el producto.');
    } catch (error) {
      try {
        if (error is DioException) {
          debugPrint('DioException creating product: ${error.requestOptions.uri}');
          debugPrint('Request headers: ${error.requestOptions.headers}');
          debugPrint('Response status: ${error.response?.statusCode}');
          debugPrint('Response data: ${error.response?.data}');
        } else {
          debugPrint('Error creating product: $error');
        }
      } catch (_) {}
      rethrow;
    }
  }
}
