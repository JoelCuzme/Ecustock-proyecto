# # 005 · Gestión de Roles y Permisos — Tareas

_Checklist de implementación técnica para el control de accesos por roles._

## Tareas

- [ ] **T01 — Diseñar el Modelo de Permiso**
  - Crear la clase `PermisoModel` en `lib/data/models/permiso_model.dart`.
  - Agregar mapeo JSON para los campos: `id_permiso`, `nombre`, `descripcion`.

- [ ] **T02 — Implementar PermissionHelper y PermissionGuard**
  - Crear la clase helper `PermissionHelper` en `lib/core/utils/permission_helper.dart` para comprobar permisos desde el JWT almacenado en `AuthSecureStorage`.
  - Crear el Widget envoltorio `PermissionGuard` en `lib/presentation/widgets/permission_guard.dart` para control visual dinámico de la UI.

- [ ] **T03 — Diseñar la Pantalla de Configuración de Permisos**
  - Crear el archivo `lib/presentation/screens/roles/roles_permissions_screen.dart`.
  - Listar los roles y mostrar una cuadrícula de permisos con interruptores interactivos (*Switches*).
  - Enviar peticiones `PUT /api/v1/roles/{id}/permisos` usando `DioClient` al cambiar el estado de un permiso.