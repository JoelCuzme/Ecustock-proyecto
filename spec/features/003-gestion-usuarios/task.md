# # 003 · Gestión de Usuarios — Tareas

_Checklist de tareas técnicas requeridas para completar la administración de usuarios._[cite: 1]

## Tareas

- [ ] **T01 — Crear Modelo de Datos de Usuario**
  - Implementar la clase `UsuarioModel` en `lib/data/models/usuario_model.dart`[cite: 1].
  - Añadir soporte para mapeo JSON de campos: `id_usuario`, `nombre`, `correo`, `rol`[cite: 1].

- [ ] **T02 — Diseñar la interfaz de Lista de Usuarios**
  - Crear el archivo `lib/presentation/screens/usuarios/usuarios_list_screen.dart`[cite: 1].
  - Implementar una llamada HTTP mediante `DioClient` para consumir `GET /api/v1/usuarios`[cite: 1].
  - Mostrar la lista de usuarios con badges que resalten su rol (`Administrativo` o `Bodega`)[cite: 1].

- [ ] **T03 — Diseñar Formulario de Creación de Cuentas**
  - Crear el archivo `lib/presentation/screens/usuarios/usuario_form_screen.dart`[cite: 1].
  - Crear campos validados para nombre, correo (con patrón de e-mail), contraseña y Dropdown de Rol[cite: 1].
  - Enviar petición `POST /api/v1/usuarios` mediante el cliente de red HTTP[cite: 1].