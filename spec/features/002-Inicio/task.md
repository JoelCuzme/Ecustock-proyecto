# # 002 · Autenticación Core (Login JWT) — Tareas

_Checklist de tareas técnicas requeridas para completar esta feature._[cite: 1]

## Tareas

- [ ] **T01 — Configuración local de almacenamiento seguro**
  - Implementar la clase `AuthSecureStorage` en `lib/core/network/auth_secure_storage.dart` usando `flutter_secure_storage`[cite: 1].
  - Crear métodos de escritura, lectura y borrado para `accessToken` y `refreshToken`[cite: 1].

- [ ] **T02 — Interceptor de red para peticiones autenticadas**
  - Implementar la clase `DioClient` en `lib/core/network/dio_client.dart`[cite: 1].
  - Añadir interceptor `onRequest` para inyectar automáticamente la cabecera `Authorization: Bearer <token>`[cite: 1].
  - Añadir interceptor `onError` para capturar el error `401 Unauthorized` y realizar el refresco automático de token enviando el `refreshToken` a `/api/v1/auth/refresh`[cite: 1].

- [ ] **T03 — Formulario de Login (IU)**
  - Crear la vista de inicio de sesión en `lib/presentation/screens/login_screen.dart`[cite: 1].
  - Diseñar el formulario con campos validados localmente (correo y contraseña)[cite: 1].
  - Integrar controladores de estado para la carga de red y visualización de errores devueltos por el backend (ej. `400 Bad Request` o `401 Unauthorized`)[cite: 1].