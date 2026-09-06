import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_profile.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/token_storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.tokenStorageService,
    required this.dioClient,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final TokenStorageService tokenStorageService;
  final DioClient dioClient;

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final accessToken = await tokenStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final response = await dioClient.client.get('/api/v1/auth/me');
      final responseData = response.data;

      if (response.statusCode == 200 && responseData is Map<String, dynamic>) {
        final userMap = responseData['user'];
        if (userMap is Map<String, dynamic>) {
          emit(AuthAuthenticated(UserProfile.fromJson(userMap)));
          return;
        }
      }

      await tokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
    } on DioException {
      await tokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
    } catch (_) {
      await tokenStorageService.clearTokens();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await dioClient.client.post(
        '/api/v1/auth/login',
        data: {
          'email': event.email.trim(),
          'password': event.password,
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
        emit(const AuthFailure(
            'La respuesta del servidor no contiene los tokens esperados.'));
        return;
      }

      if (userMap is! Map<String, dynamic>) {
        emit(const AuthFailure(
            'La respuesta del servidor no contiene el perfil del usuario.'));
        return;
      }

      await tokenStorageService.saveTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      emit(AuthAuthenticated(UserProfile.fromJson(userMap)));
    } on DioException catch (error) {
      final errorData = error.response?.data;
      final message = errorData is Map<String, dynamic>
          ? (errorData['message']?.toString() ?? 'Credenciales incorrectas.')
          : error.message ?? 'No se pudo iniciar sesión.';

      emit(AuthFailure(message));
    } catch (_) {
      emit(const AuthFailure('No se pudo iniciar sesión. Intenta de nuevo.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenStorageService.clearTokens();
    emit(const AuthUnauthenticated());
  }
}
