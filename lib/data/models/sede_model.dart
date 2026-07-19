class SedeModel {
  final int idSede;
  final int idOrganizacion;
  final String nombre;
  final String direccion;
  final String codigoEstablecimiento;

  SedeModel({
    required this.idSede,
    required this.idOrganizacion,
    required this.nombre,
    required this.direccion,
    required this.codigoEstablecimiento,
  });

  factory SedeModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id_sede'];
    final dynamic idOrgValue = json['id_organizacion'];
    return SedeModel(
      idSede: idValue is int
          ? idValue
          : int.tryParse(idValue?.toString() ?? '') ?? 0,
      idOrganizacion: idOrgValue is int
          ? idOrgValue
          : int.tryParse(idOrgValue?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      codigoEstablecimiento: json['codigo_establecimiento']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_sede': idSede,
      'id_organizacion': idOrganizacion,
      'nombre': nombre,
      'direccion': direccion,
      'codigo_establecimiento': codigoEstablecimiento,
    };
  }
}
