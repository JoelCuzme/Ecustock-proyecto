import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/usuario_model.dart';
import 'package:ecustock/presentation/screens/usuarios/asignar_rol_screen.dart';
import 'package:ecustock/presentation/screens/usuarios/usuario_form_screen.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  static const String _baseUrl = 'http://192.168.1.2:3000';

  late final DioClient _dioClient;
  late Future<List<UsuarioModel>> _usuariosFuture;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
    _usuariosFuture = _fetchUsuarios();
  }

  Future<List<UsuarioModel>> _fetchUsuarios() async {
    final response = await _dioClient.client.get('/api/v1/usuarios');
    final data = response.data;

    if (data is List) {
      return data
          .map<UsuarioModel>(
            (item) => UsuarioModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    if (data is Map<String, dynamic> && data['usuarios'] is List) {
      return (data['usuarios'] as List)
          .map<UsuarioModel>(
            (item) => UsuarioModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('Formato de respuesta inesperado al consultar usuarios.');
  }

  Color _badgeColor(String rol) {
    final normalized = rol.toLowerCase();
    if (normalized.contains('administrativo')) {
      return Colors.green;
    }
    if (normalized.contains('bodega')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  String _displayRole(String rol) {
    final normalized = rol.toLowerCase();
    if (normalized.contains('administrativo')) {
      return 'Administrativo';
    }
    if (normalized.contains('bodega')) {
      return 'Bodega';
    }
    return rol.isNotEmpty ? rol : 'Sin rol';
  }

  void _refresh() {
    setState(() {
      _usuariosFuture = _fetchUsuarios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
      ),
      body: FutureBuilder<List<UsuarioModel>>(
        future: _usuariosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final String errorMessage = snapshot.error is DioException
                ? (snapshot.error as DioException).message ??
                    'Error desconocido'
                : snapshot.error.toString();
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No se pudo cargar la lista de usuarios.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? <UsuarioModel>[];
          if (usuarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.group, size: 72, color: Colors.black54),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay usuarios registrados aún.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Actualizar'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(usuario.nombre),
                subtitle: Text(usuario.correo),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _badgeColor(usuario.rol).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _displayRole(usuario.rol),
                    style: TextStyle(
                      color: _badgeColor(usuario.rol).withAlpha(230),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => AsignarRolScreen(usuario: usuario),
                    ),
                  );
                  if (updated == true) {
                    _refresh();
                  }
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemCount: usuarios.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const UsuarioFormScreen(),
            ),
          );

          if (created == true) {
            _refresh();
          }
        },
        tooltip: 'Nuevo usuario',
        child: const Icon(Icons.add),
      ),
    );
  }
}
