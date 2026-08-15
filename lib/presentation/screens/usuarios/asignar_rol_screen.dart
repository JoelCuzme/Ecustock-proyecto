import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/asignacion_rol_model.dart';
import 'package:ecustock/data/models/usuario_model.dart';

class AsignarRolScreen extends StatefulWidget {
  const AsignarRolScreen({super.key, required this.usuario});

  final UsuarioModel usuario;

  @override
  State<AsignarRolScreen> createState() => _AsignarRolScreenState();
}

class _AsignarRolScreenState extends State<AsignarRolScreen> {
  static const String _baseUrl = 'http://192.168.1.2:3000';
  static const List<String> _roles = [
    'Administrativo',
    'Bodega',
  ];

  late final DioClient _dioClient;
  late String _selectedRol;
  late String _originalRol;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
    _originalRol = _normalizeRole(widget.usuario.rol);
    _selectedRol = _originalRol;
  }

  String _normalizeRole(String rol) {
    final normalized = rol.toLowerCase();
    if (normalized.contains('administrativo')) {
      return 'Administrativo';
    }
    if (normalized.contains('bodega')) {
      return 'Bodega';
    }
    return _roles.first;
  }

  Future<void> _guardarRol() async {
    setState(() {
      _isSaving = true;
    });

    final asignacionRol = AsignacionRolModel(
      idUsuario: widget.usuario.idUsuario,
      nuevoRol: _selectedRol,
    );

    try {
      await _dioClient.client.patch(
        '/api/v1/usuarios/${widget.usuario.idUsuario}/rol',
        data: asignacionRol.toJson(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rol actualizado correctamente.')),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      final message = error.response?.data['message']?.toString() ??
          error.message ??
          'Ocurrió un error al actualizar el rol.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo actualizar el rol.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Rol'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Usuario: ${widget.usuario.nombre}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Correo: ${widget.usuario.correo}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Rol actual: $_originalRol',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona el nuevo rol',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRol,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: _roles
                  .map(
                    (role) => DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    ),
                  )
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedRol = value;
                      });
                    },
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving || _selectedRol == _originalRol
                        ? null
                        : _guardarRol,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirmar Cambio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
