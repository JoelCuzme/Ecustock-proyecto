class PermisoModel {
  final int idPermiso;
  final String nombre;
  final String descripcion;

  PermisoModel({
    required this.idPermiso,
    required this.nombre,
    required this.descripcion,
  });

  factory PermisoModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id_permiso'];
    return PermisoModel(
      idPermiso: idValue is int
          ? idValue
          : int.tryParse(idValue?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_permiso': idPermiso,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}
