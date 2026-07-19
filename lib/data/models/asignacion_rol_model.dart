class AsignacionRolModel {
  final int idUsuario;
  final String nuevoRol;

  AsignacionRolModel({
    required this.idUsuario,
    required this.nuevoRol,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'rol': nuevoRol,
    };
  }
}
