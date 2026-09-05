class Product {
  Product({
    required this.id,
    required this.nombre,
    required this.codigoBarras,
    required this.descripcion,
    required this.stock,
    required this.precioCosto,
    required this.precioVenta,
  });

  final int id;
  final String nombre;
  final String codigoBarras;
  final String descripcion;
  final int stock; // mapped from 'stock_actual'
  final double precioCosto;
  final double precioVenta;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      codigoBarras: json['codigo_barras']?.toString() ?? json['codigoBarras']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      stock: json['stock_actual'] is int
          ? json['stock_actual'] as int
          : int.tryParse(json['stock_actual']?.toString() ?? json['stock']?.toString() ?? '') ?? 0,
      precioCosto: json['precio_costo'] is num
          ? (json['precio_costo'] as num).toDouble()
          : double.tryParse(json['precio_costo']?.toString() ?? '') ?? 0.0,
      precioVenta: json['precio_venta'] is num
          ? (json['precio_venta'] as num).toDouble()
          : double.tryParse(json['precio_venta']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final payload = <String, dynamic>{
      'nombre': nombre,
      'codigo_barras': codigoBarras,
      'descripcion': descripcion,
      'stock_actual': stock,
      'precio_costo': precioCosto,
      'precio_venta': precioVenta,
    };

    if (includeId && id != 0) {
      payload['id'] = id;
    }

    return payload;
  }
}
