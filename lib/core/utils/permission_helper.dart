import 'dart:convert';

import 'package:ecustock/core/network/auth_secure_storage.dart';

/// Utility to inspect the current user's permissions encoded inside a JWT token.
class PermissionHelper {
  PermissionHelper([AuthSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? AuthSecureStorage();

  final AuthSecureStorage _secureStorage;

  Future<Map<String, dynamic>> _decodeJwtPayload(String token) async {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('El token JWT no tiene el formato esperado.');
    }

    final payload = parts[1];
    final normalizedPayload = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalizedPayload));
    final decodedJson = jsonDecode(decoded);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException(
          'El payload JWT no es un objeto JSON válido.');
    }

    return decodedJson;
  }

  Future<List<String>> _extractPermissionsFromPayload(
      Map<String, dynamic> payload) async {
    final dynamic rawPermissions = payload['permisos'] ??
        payload['permissions'] ??
        payload['permission'] ??
        payload['perms'];

    if (rawPermissions == null) {
      return [];
    }

    if (rawPermissions is String) {
      try {
        final decoded = jsonDecode(rawPermissions);
        if (decoded is Iterable) {
          return decoded.map((item) => item.toString()).toList();
        }
      } catch (_) {
        return [rawPermissions];
      }
    }

    if (rawPermissions is Iterable) {
      return rawPermissions.map((item) {
        if (item is Map<String, dynamic>) {
          return item['nombre']?.toString() ??
              item['permission']?.toString() ??
              item['permiso']?.toString() ??
              item.toString();
        }

        return item.toString();
      }).toList();
    }

    if (rawPermissions is Map<String, dynamic>) {
      return rawPermissions.entries.map((entry) {
        final value = entry.value;
        if (value is bool || value is num || value is String) {
          return entry.key.toString();
        }

        return value.toString();
      }).toList();
    }

    return [rawPermissions.toString()];
  }

  Future<List<String>> getPermissions() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    try {
      final payload = await _decodeJwtPayload(token);
      return _extractPermissionsFromPayload(payload);
    } catch (_) {
      return [];
    }
  }

  Future<bool> hasPermission(String permissionName) async {
    if (permissionName.isEmpty) {
      return false;
    }

    final permissions = await getPermissions();
    return permissions.any(
      (permission) => permission.toLowerCase() == permissionName.toLowerCase(),
    );
  }
}
