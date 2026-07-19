# # 003 · Gestión de Usuarios — Plan

_Cómo se implementa la administración y consulta de perfiles de usuario en EcuStock. Debe respetar la consistencia de roles y auditoría._

## Enfoque

Implementar un módulo de consulta, creación y asignación de roles para los usuarios del sistema[cite: 1]. El flujo conecta el cliente móvil (Flutter) con la API REST conectada a MariaDB[cite: 1]. Cada usuario creado se asocia a un rol estricto (`Administrativo` o `Bodega`) para controlar dinámicamente qué vistas y permisos se le habilitan en la app[cite: 1]. Toda creación de registros de auditoría (ventas o bodega) guardará la relación con el `id_usuario` activo[cite: 1].

## Implementación

1. **`backend/routes/usuarios.js` (Backend)** — Endpoints privados de administración de cuentas[cite: 1]:
   - `GET /api/v1/usuarios` (Solo accesible para Administradores): Recupera la lista de usuarios registrados[cite: 1].
   - `POST /api/v1/usuarios` (Solo accesible para Administradores): Registra un nuevo usuario en la tabla `usuarios` de MariaDB, aplicando un hash seguro a su contraseña (ej. bcrypt) antes de almacenarla[cite: 1].

2. **`lib/data/models/usuario_model.dart` (Flutter)** — Modelo de datos en Dart para estructurar al usuario[cite: 1]:
   - Propiedades: `idUsuario`, `nombre`, `correo`, `rol`[cite: 1].
   - Métodos `fromJson` y `toJson` para la deserialización limpia de las respuestas de la API[cite: 1].

3. **`lib/presentation/screens/usuarios/usuarios_list_screen.dart` (Flutter)** — Vista para listar el personal activo de la empresa (útil para administración) consumiendo el servicio REST de usuarios[cite: 1].

4. **`lib/presentation/screens/usuarios/usuario_form_screen.dart` (Flutter)** — Formulario de registro de nuevos colaboradores donde se define de forma obligatoria el rol (`Administrativo` o `Bodega`)[cite: 1].

## Decisiones

- **Roles fijos (Enum) vs. Roles dinámicos:** Se implementan roles fijos (`Administrativo` y `Bodega`) mapeados como ENUM en la base de datos MariaDB para simplificar el flujo y robustecer las validaciones dinámicas dentro de la aplicación móvil[cite: 1].
- **Cifrado de credenciales únicamente en el backend:** El cliente móvil envía la contraseña en texto plano cifrada por protocolo HTTPS; el backend se encarga de aplicar un algoritmo de hash seguro irreversible antes de insertarla en la tabla InnoDB de MariaDB[cite: 1].

## Riesgos

- **Asignación incorrecta de privilegios:** Si un bodeguero logra crear un usuario con perfil Administrativo, podría saltarse las restricciones de facturación[cite: 1].
  - **Mitigación:** El backend validará a través de un middleware de autorización que únicamente los usuarios con rol administrativo superior puedan invocar el endpoint de creación de usuarios[cite: 1].