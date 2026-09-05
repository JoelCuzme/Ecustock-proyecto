import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ecustock/core/network/auth_secure_storage.dart';
import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/core/services/app_session.dart';
import 'package:ecustock/core/models/user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _baseUrl = 'http://192.168.1.2:3000';

  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late final DioClient _dioClient;
  late final AuthSecureStorage _secureStorage;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
    _secureStorage = AuthSecureStorage();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    const emailPattern = r"^[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$";
    return RegExp(emailPattern).hasMatch(value);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dioClient.client.post(
        '/api/v1/auth/login',
        data: {
          'email': _correoController.text.trim(),
          'password': _passwordController.text,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      final token = data?['token']?.toString();
      final refreshToken = data?['refreshToken']?.toString();
      final userMap = data?['user'];

      if (token == null ||
          token.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'La respuesta del servidor no contiene los tokens esperados.',
        );
      }

      await _secureStorage.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      if (userMap is Map<String, dynamic>) {
        AppSession().currentUser = UserProfile.fromJson(userMap);
      }

      if (!mounted) {
        return;
      }

      context.go('/home');
    } on DioException catch (error) {
      final errorData = error.response?.data;
      final message = errorData is Map<String, dynamic>
          ? (errorData['message']?.toString() ?? 'Credenciales incorrectas.')
          : error.response?.statusMessage ??
              error.message ??
              'No se pudo iniciar sesión.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo iniciar sesión. Intenta de nuevo.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bienvenido a EcuStock',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingresa con tu correo electrónico y contraseña.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es obligatorio.';
                        }
                        if (!_isValidEmail(value.trim())) {
                          return 'Introduce un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es obligatoria.';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Ingresando...'),
                                ],
                              )
                            : const Text('Ingresar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
