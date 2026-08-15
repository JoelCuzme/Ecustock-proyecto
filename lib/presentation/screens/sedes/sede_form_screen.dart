import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/network/dio_client.dart';

class SedeFormScreen extends StatefulWidget {
  const SedeFormScreen({super.key});

  @override
  State<SedeFormScreen> createState() => _SedeFormScreenState();
}

class _SedeFormScreenState extends State<SedeFormScreen> {
  static const String _baseUrl = 'http://192.168.1.2:3000';

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _codigoController = TextEditingController();
  bool _isSaving = false;

  late final DioClient _dioClient;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _saveSede() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final sedeData = {
        'nombre': _nombreController.text.trim(),
        'direccion': _direccionController.text.trim(),
        'codigo_establecimiento': _codigoController.text.trim(),
      };

      await _dioClient.client.post(
        '/api/v1/sedes',
        data: sedeData,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sede creada correctamente.')),
      );

      Navigator.of(context).pop(true);
    } on DioException catch (error) {
      final message = error.response?.data['message']?.toString() ??
          error.message ??
          'Ocurrió un error al crear la sede.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear la sede.')),
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

  bool _isValidCodigo(String value) {
    return RegExp(r'^\d{3}$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Sede'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre comercial',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección completa',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es obligatoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  labelText: 'Código del establecimiento',
                  hintText: 'Ej. 001',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El código es obligatorio.';
                  }
                  if (!_isValidCodigo(value.trim())) {
                    return 'El código debe tener exactamente 3 dígitos.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSede,
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text('Guardar sede'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
