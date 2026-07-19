import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para persistir el JWT de autenticación de forma segura.
///
/// Este servicio usa `flutter_secure_storage` para guardar el token en el
/// almacenamiento seguro del dispositivo, evitando que quede en texto plano.
class StorageService {
  StorageService._({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static final StorageService _instance = StorageService._();

  factory StorageService() => _instance;

  static const String _tokenKey = 'jwt_token';

  final FlutterSecureStorage _secureStorage;

  /// Guarda el JWT en el almacenamiento seguro.
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Recupera el JWT actualmente guardado.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Elimina el JWT guardado cuando el usuario cierra sesión.
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Comprueba si existe un token válido almacenado.
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
