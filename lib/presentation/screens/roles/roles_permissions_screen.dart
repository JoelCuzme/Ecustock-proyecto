import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/permiso_model.dart';
import 'package:ecustock/presentation/widgets/permission_guard.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  static const String _baseUrl = 'http://192.168.1.2:3000';

  final DioClient _dioClient = DioClient(baseUrl: _baseUrl);
  final List<_RoleItem> _roles = [];
  final Map<int, PermisoModel> _permissionsById = {};
  final Map<int, Set<int>> _rolePermissionMap = {};

  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<List<PermisoModel>> _parsePermisos(dynamic raw) async {
    if (raw is Iterable) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(PermisoModel.fromJson)
          .toList();
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Iterable) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(PermisoModel.fromJson)
              .toList();
        }
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dioClient.client.get('/api/v1/roles');
      final data = response.data;

      if (data is! Iterable) {
        throw const FormatException(
            'Respuesta inesperada al cargar los roles.');
      }

      _roles.clear();
      _permissionsById.clear();
      _rolePermissionMap.clear();

      for (final rawRole in data) {
        if (rawRole is! Map<String, dynamic>) {
          continue;
        }

        final int roleId = rawRole['id_rol'] is int
            ? rawRole['id_rol'] as int
            : int.tryParse(rawRole['id_rol']?.toString() ?? '') ?? 0;
        final String roleName =
            rawRole['nombre']?.toString() ?? 'Rol desconocido';
        final permisos =
            await _parsePermisos(rawRole['permisos'] ?? rawRole['permissions']);
        final permisoIds = <int>{};

        for (final permiso in permisos) {
          permisoIds.add(permiso.idPermiso);
          _permissionsById[permiso.idPermiso] = permiso;
        }

        _roles.add(_RoleItem(
          idRol: roleId,
          nombre: roleName,
          permisoIds: permisoIds,
        ));
      }

      _selectedRoleId = _roles.isNotEmpty ? _roles.first.idRol : null;
      for (final role in _roles) {
        _rolePermissionMap[role.idRol] = Set<int>.from(role.permisoIds);
      }
    } catch (error) {
      _errorMessage = error is DioException
          ? error.message
          : 'No se pudieron cargar los roles. Intenta de nuevo.';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePermission(int permisoId, bool enabled) async {
    final selectedRoleId = _selectedRoleId;
    if (selectedRoleId == null) {
      return;
    }

    final rolePermissionIds = _rolePermissionMap[selectedRoleId] ?? <int>{};
    final previousSelection = Set<int>.from(rolePermissionIds);

    setState(() {
      if (enabled) {
        rolePermissionIds.add(permisoId);
      } else {
        rolePermissionIds.remove(permisoId);
      }

      _rolePermissionMap[selectedRoleId] = rolePermissionIds;
      _isUpdating = true;
    });

    try {
      await _dioClient.client.put(
        '/api/v1/roles/$selectedRoleId/permisos',
        data: {
          'permisos': rolePermissionIds.toList(),
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _rolePermissionMap[selectedRoleId] = previousSelection;
        });
      }

      final message = error is DioException
          ? error.message ??
              'No se pudo actualizar el permiso. Intenta de nuevo.'
          : 'No se pudo actualizar el permiso. Intenta de nuevo.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _selectRole(int roleId) {
    if (_selectedRoleId == roleId) {
      return;
    }

    setState(() {
      _selectedRoleId = roleId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles y Permisos'),
      ),
      body: PermissionGuard(
        permission: 'administrar_roles',
        deniedChild: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'No tienes permiso para administrar roles y permisos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    final selectedRole = _roles.firstWhere(
      (role) => role.idRol == _selectedRoleId,
      orElse: () => _roles.first,
    );
    final selectedPermissions =
        _rolePermissionMap[selectedRole.idRol] ?? <int>{};
    final allPermissions = _permissionsById.values.toList()
      ..sort((a, b) => a.nombre.compareTo(b.nombre));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecciona un rol para editar sus permisos.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _roles
                .map(
                  (role) => ChoiceChip(
                    label: Text(role.nombre),
                    selected: role.idRol == _selectedRoleId,
                    onSelected: (_) => _selectRole(role.idRol),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          if (_isUpdating)
            const LinearProgressIndicator(
              minHeight: 4,
            ),
          const SizedBox(height: 12),
          Expanded(
            child: allPermissions.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron permisos disponibles.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    itemCount: allPermissions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final permiso = allPermissions[index];
                      final enabled =
                          selectedPermissions.contains(permiso.idPermiso);
                      return SwitchListTile(
                        title: Text(permiso.nombre),
                        subtitle: Text(permiso.descripcion),
                        value: enabled,
                        onChanged: (value) =>
                            _togglePermission(permiso.idPermiso, value),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RoleItem {
  _RoleItem({
    required this.idRol,
    required this.nombre,
    required this.permisoIds,
  });

  final int idRol;
  final String nombre;
  final Set<int> permisoIds;
}
