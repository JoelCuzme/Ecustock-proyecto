# # 006 · Asignación de Roles a Usuarios — Plan

_Cómo se implementa la asignación y actualización de roles para los usuarios existentes en EcuStock._

## Enfoque

Implementar una extensión en el módulo administrativo para permitir la reasignación de roles de forma dinámica. El cliente móvil (Flutter) consumirá un endpoint de actualización que modificará el campo `rol` del usuario en la tabla de MariaDB. Al realizar este cambio, la próxima vez que el usuario inicie sesión o refresque su token, heredará automáticamente la nueva matriz de permisos definida para su nuevo rol.

## Implementación

1. **Endpoints de la API (Backend)**:
   - `PATCH /api/v1/usuarios/{id}/rol` -> Actualiza únicamente el rol del usuario especificado por ID (Solo accesible por cuentas con rol `Administrativo`).

2. **`lib/data/models/asignacion_rol_model.dart` (Flutter)** — Modelo de datos de soporte para enviar la actualización de rol a la API:
   - Atributos: `idUsuario`, `nuevoRol`.

3. **`lib/presentation/screens/usuarios/asignar_rol_screen.dart` (Flutter)** — Pantalla de gestión donde el administrador selecciona a un colaborador de la lista y, mediante un cuadro de diálogo o selector de opciones, actualiza su rol de manera inmediata.

## Decisiones

- **Uso del método HTTP PATCH:** Se prefiere `PATCH` sobre `PUT` debido a que es una actualización parcial que solo modifica el atributo `rol` de la entidad de usuario en MariaDB, manteniendo intactas las contraseñas, nombres y correos.
- **Forzar cierre de sesión remoto implícito:** Al cambiar el rol en la base de datos, el backend invalidará el `refreshToken` anterior del usuario afectado en MariaDB para obligarlo a reautenticarse y evitar que use permisos antiguos.

## Riesgos

- **Auto-degradación de privilegios:** Un administrador podría cambiarse el rol a sí mismo por error hacia 'Bodega', perdiendo el acceso a las pantallas de configuración.
  - **Mitigación:** El backend y la interfaz móvil validarán que un usuario no pueda modificar su propio ID en la pantalla de asignación de roles.