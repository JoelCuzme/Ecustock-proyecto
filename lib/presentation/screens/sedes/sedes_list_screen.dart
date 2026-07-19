import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/data/models/sede_model.dart';
import 'package:ecustock/presentation/screens/sedes/sede_form_screen.dart';

class SedesListScreen extends StatefulWidget {
  const SedesListScreen({super.key});

  @override
  State<SedesListScreen> createState() => _SedesListScreenState();
}

class _SedesListScreenState extends State<SedesListScreen> {
  static const String _baseUrl = 'http://localhost:3000';

  late final DioClient _dioClient;
  late Future<List<SedeModel>> _sedesFuture;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
    _sedesFuture = _fetchSedes();
  }

  Future<List<SedeModel>> _fetchSedes() async {
    final response = await _dioClient.client.get('/api/v1/sedes');
    final data = response.data;

    if (data is List) {
      return data
          .map<SedeModel>(
            (item) => SedeModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    if (data is Map<String, dynamic> && data['sedes'] is List) {
      return (data['sedes'] as List)
          .map<SedeModel>(
            (item) => SedeModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    throw Exception('Formato de respuesta inesperado al consultar sedes.');
  }

  void _refresh() {
    setState(() {
      _sedesFuture = _fetchSedes();
    });
  }

  String _buildSubtitle(SedeModel sede) {
    return '${sede.codigoEstablecimiento.isNotEmpty ? 'Est. ${sede.codigoEstablecimiento} · ' : ''}${sede.direccion}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Sedes'),
      ),
      body: FutureBuilder<List<SedeModel>>(
        future: _sedesFuture,
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
                      'No se pudo cargar la lista de sedes.',
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

          final sedes = snapshot.data ?? <SedeModel>[];
          if (sedes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city,
                        size: 72, color: Colors.black54),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay sedes registradas todavía.',
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
              final sede = sedes[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(sede.nombre),
                subtitle: Text(_buildSubtitle(sede)),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withAlpha(31),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    sede.nombre.isNotEmpty ? sede.nombre[0].toUpperCase() : 'S',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemCount: sedes.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute<bool>(
              builder: (_) => const SedeFormScreen(),
            ),
          );

          if (created == true) {
            _refresh();
          }
        },
        tooltip: 'Nueva sede',
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}
