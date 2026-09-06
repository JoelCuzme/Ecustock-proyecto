class Product {
  Product({
    required this.id,
    required this.nombre,
    required this.codigoBarras,
    required this.stock,
    required this.precioCosto,
    required this.precioVenta,
  });

  final int id;
  final String nombre;
  final String codigoBarras;
  final int stock;
  final double precioCosto;
  final double precioVenta;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      codigoBarras: json['codigo_barras']?.toString() ??
          json['codigoBarras']?.toString() ??
          '',
      stock: json['stock'] is int
          ? json['stock'] as int
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      precioCosto: json['precio_costo'] is num
          ? (json['precio_costo'] as num).toDouble()
          : double.tryParse(json['precio_costo']?.toString() ?? '') ?? 0,
      precioVenta: json['precio_venta'] is num
          ? (json['precio_venta'] as num).toDouble()
          : double.tryParse(json['precio_venta']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final payload = <String, dynamic>{
      'nombre': nombre,
      'codigo_barras': codigoBarras,
      'stock': stock,
      'precio_costo': precioCosto,
      'precio_venta': precioVenta,
    };

    if (includeId && id != 0) {
      payload['id'] = id;
    }

    return payload;
  }
}
