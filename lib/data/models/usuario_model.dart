class UsuarioModel {
  final int idUsuario;
  final String nombre;
  final String correo;
  final String rol;

  UsuarioModel({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id_usuario'];
    return UsuarioModel(
      idUsuario: idValue is int
          ? idValue
          : int.tryParse(idValue?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      rol: json['rol']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
    };
  }
}
