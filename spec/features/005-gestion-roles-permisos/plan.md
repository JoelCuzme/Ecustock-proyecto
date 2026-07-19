# # 005 · Gestión de Roles y Permisos — Plan

_Cómo se implementa el control de acceso basado en roles (RBAC) y la asignación de permisos granulares en EcuStock._

## Enfoque

Implementar un sistema dinámico de Control de Acceso Basado en Roles (RBAC). El backend (API REST + MariaDB) proveerá la lista de permisos asignados a cada rol en el login dentro del payload del JWT. En el cliente móvil (Flutter), crearemos un helper de seguridad centralizado y un widget envoltorio (Guard) que habilitará o deshabilitará componentes de la interfaz de forma dinámica según la lista de permisos del usuario logueado.

## Implementación

1. **Estructura de Base de Datos (MariaDB - InnoDB)**:
   - Tabla `permisos`: `id_permiso` (PK), `nombre` (ej. 'crear_factura', 'ajustar_stock').
   - Tabla intermedia `rol_permiso`: `id_rol` (FK), `id_permiso` (FK) para relacionar qué puede hacer cada rol.

2. **Endpoints de la API (Backend)**:
   - `GET /api/v1/roles` -> Lista los roles con sus respectivos permisos asociados.
   - `PUT /api/v1/roles/{id}/permisos` -> Actualiza los permisos asociados a un rol específico (Solo accesible por administradores).

3. **`lib/data/models/permiso_model.dart` (Flutter)** — Modelo de datos para los permisos individuales:
   - Atributos: `idPermiso`, `nombre`, `descripcion`.

4. **`lib/core/utils/permission_helper.dart` (Flutter)** — Utilidad global para verificar permisos de forma limpia en el código:
   - `bool hasPermission(String permissionName)` -> Devuelve verdadero si el usuario activo tiene ese permiso en su sesión.

5. **`lib/presentation/widgets/permission_guard.dart` (Flutter)** — Widget reutilizable que envuelve elementos de la UI:
   - Si el usuario tiene el permiso requerido, muestra el widget hijo; de lo contrario, oculta el componente o muestra una vista de "Acceso denegado".

6. **`lib/presentation/screens/roles/roles_permissions_screen.dart` (Flutter)** — Panel administrativo donde se listan los roles y se pueden activar/desactivar sus permisos mediante interruptores (*switches*).

## Decisiones

- **Carga de permisos en JWT:** Los permisos activos se serializan dentro del token JWT para evitar consultas constantes a MariaDB en cada petición privada al servidor.
- **PermissionGuard en Flutter:** En lugar de condicionar cada botón de forma manual con un `if`, envolveremos los elementos en un widget `PermissionGuard` para mantener el código de presentación limpio y legible.

## Riesgos

- **Desincronización de sesión:** Si un administrador revoca un permiso en la base de datos, el usuario podría seguir ejecutándolo en la app hasta que su sesión de JWT expire.
  - **Mitigación:** Al realizar peticiones críticas en el servidor, el backend consultará en MariaDB de forma inmediata la validez del permiso en lugar de confiar ciegamente en el payload del JWT.