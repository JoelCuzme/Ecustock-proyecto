import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/product.dart';

class ProductRepository {
  ProductRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient(baseUrl: _baseUrl);

  static const String _baseUrl = 'http://192.168.1.2:3000';

  final DioClient _dioClient;

  Future<List<Product>> getProducts() async {
    final response = await _dioClient.client.get('/api/v1/productos');
    final data = response.data;

    if (data is List) {
      return data
          .map<Product>(
            (item) => Product.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    if (data is Map<String, dynamic> && data['products'] is List) {
      return (data['products'] as List)
          .map<Product>(
            (item) => Product.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List)
          .map<Product>(
            (item) => Product.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    return const [];
  }

  Future<Product> addProduct(Product product) async {
    final response = await _dioClient.client.post(
      '/api/v1/productos',
      data: product.toJson(includeId: false),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('product')) {
        final productData = data['product'];
        if (productData is Map<String, dynamic>) {
          return Product.fromJson(productData);
        }
      }

      return Product.fromJson(data);
    }

    throw Exception('Respuesta inesperada al crear el producto.');
  }

  Future<Product> getProductByBarcode(String barcode) async {
    final response = await _dioClient.client.get(
      '/api/v1/productos/codigo/${Uri.encodeComponent(barcode)}',
    );
    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['product'] is Map<String, dynamic>) {
      return Product.fromJson(data['product'] as Map<String, dynamic>);
    }

    throw Exception('Respuesta inesperada al consultar el producto.');
  }

  Future<Product> registerStockMovement({
    required int productId,
    required String type,
    required int quantity,
  }) async {
    final response = await _dioClient.client.post(
      '/api/v1/productos/$productId/movimientos',
      data: {'tipo': type, 'cantidad': quantity},
    );
    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['product'] is Map<String, dynamic>) {
      return Product.fromJson(data['product'] as Map<String, dynamic>);
    }

    throw Exception('Respuesta inesperada al registrar el movimiento.');
  }
}
