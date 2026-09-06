```markdown
# Task: Implementación de Autenticación, Estado Global y Rutas Protegidas

## Instrucciones para Copilot:

Implementar el flujo completo de login, persistencia, manejo de estado y rutas con las siguientes tareas atómicas:

- [ ] **Paso 1: Modelos y Almacenamiento Local**
  - Crear `UserModel` (`id_usuario`, `nombre`, `correo`, `rol`, `token`).
  - Crear `TokenStorageService` para guardar, leer y borrar el token y sesión de usuario.

- [ ] **Paso 2: Repositorio y Capa de Red**
  - Configurar llamada POST a `/api/v1/auth/login` con `Dio`.
  - Parsear respuesta y manejar errores HTTP (400, 401, conexión).

- [ ] **Paso 3: Bloque de Estado (AuthBloc)**
  - Implementar eventos: `LoginSubmitted`, `LogoutRequested`, `CheckAuthStatus`.
  - Emitir estados correspondientes y persistir sesión en `Authenticated`.
  - Limpiar almacenamiento en `LogoutRequested`.

- [ ] **Paso 4: Pantalla de Login (Formulario y Validaciones)**
  - Construir `LoginPage` con `Form`, `TextFormField` para correo (regex) y contraseña (longitud mínima).
  - Integrar `BlocConsumer<AuthBloc, AuthState>` para mostrar carga (`CircularProgressIndicator`) y errores (`SnackBar`).
  - Botón de submit que despacha `LoginSubmitted`.

- [ ] **Paso 5: Rutas y Protección con GoRouter**
  - Definir rutas `/login` y `/home` (o dashboard con botón de cerrar sesión).
  - Implementar guardia `redirect` que evalúe si el usuario está autenticado:
    - Si no está autenticado y trata de entrar a ruta protegida -> redirigir a `/login`.
    - Si ya está autenticado y está en `/login` -> redirigir a `/home`.

- [ ] **Paso 6: Botón de Cierre de Sesión**
  - En la vista principal protegida, agregar botón de Logout que dispare `LogoutRequested()`.
  - Comprobar que redirige a `/login` y no permite regresar con el botón atrás.
```
