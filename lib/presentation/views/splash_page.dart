import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:ecustock/core/models/user_profile.dart';
import 'package:ecustock/core/network/auth_secure_storage.dart';
import 'package:ecustock/core/network/dio_client.dart';
import 'package:ecustock/core/services/app_session.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const String _baseUrl = 'http://localhost:3000';

  final AuthSecureStorage _secureStorage = AuthSecureStorage();
  late final DioClient _dioClient;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _dioClient = DioClient(baseUrl: _baseUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateSession();
    });
  }

  Future<void> _validateSession() async {
    final token = await _secureStorage.getAccessToken();

    if (token == null || token.isEmpty) {
      _navigateToLogin();
      return;
    }

    try {
      final response = await _dioClient.client.get('/api/v1/auth/me');
      final responseData = response.data;

      if (response.statusCode == 200 && responseData is Map<String, dynamic>) {
        final userMap = responseData['user'];
        if (userMap is Map<String, dynamic>) {
          AppSession().currentUser = UserProfile.fromJson(userMap);
        }
        _navigateToHome();
        return;
      }
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = error.response?.statusCode == 401
            ? 'Sesión expirada. Por favor inicia sesión nuevamente.'
            : 'No se pudo validar la sesión. Por favor inicia sesión.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'No se pudo establecer conexión con el servidor.';
      });
    }

    await _secureStorage.clearTokens();
    AppSession().clear();
    _navigateToLogin();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 120),
                const SizedBox(height: 32),
                const Text(
                  'EcuStock',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Validando tu sesión, por favor espera...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
