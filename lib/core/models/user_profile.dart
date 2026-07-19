class UserProfile {
  UserProfile({
    required this.id,
    required this.nombre,
    required this.email,
    this.rol,
    this.sede,
  });

  final int id;
  final String nombre;
  final String email;
  final String? rol;
  final String? sede;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];

    return UserProfile(
      id: idValue is int
          ? idValue
          : int.tryParse(idValue?.toString() ?? '') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString(),
      sede: json['sede']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      if (rol != null) 'rol': rol,
      if (sede != null) 'sede': sede,
    };
  }
}
