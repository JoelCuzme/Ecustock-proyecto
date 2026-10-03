import 'package:flutter_test/flutter_test.dart';

import 'package:ecustock/data/models/product.dart';

void main() {
  test('serializes required product fields with MariaDB JSON names and numbers',
      () {
    final product = Product(
      id: 0,
      nombre: 'Producto válido',
      codigoBarras: '12345678',
      stock: 12,
      stockMinimo: 3,
      precioCosto: 4.25,
      precioVenta: 6.5,
    );

    final payload = product.toJson(includeId: false);

    expect(payload.keys.toSet(), {
      'codigo_barras',
      'nombre',
      'stock_actual',
      'stock_minimo',
      'precio_costo',
      'precio_venta',
    });
    expect(payload['codigo_barras'], '12345678');
    expect(payload['nombre'], 'Producto válido');
    expect(payload['stock_actual'], 12);
    expect(payload['stock_minimo'], 3);
    expect(payload['precio_costo'], 4.25);
    expect(payload['precio_venta'], 6.5);
    expect(payload['stock_actual'], isA<int>());
    expect(payload['stock_minimo'], isA<int>());
    expect(payload['precio_costo'], isA<double>());
    expect(payload['precio_venta'], isA<double>());
    expect(payload.values, everyElement(isNotNull));
  });
}
