# # 009 · Sesiones Persistentes — Tareas

_Checklist de desarrollo técnico para la persistencia de sesiones._

## Tareas

- [ ] **T01 — Crear Endpoint de Verificación de Sesión (`/auth/me`) en Node.js**
  - Implementar la ruta protegida que decodifique el token JWT y devuelva el perfil actual del usuario directamente de la base de datos MariaDB.
  - Asegurar que la documentación de Swagger exponga este endpoint y requiera la autenticación `BearerAuth`.

- [ ] **T02 — Diseñar Flujo de Inicialización (Splash Route) en Flutter**
  - Crear una pantalla de transición visual (`SplashPage`) que se ejecute antes de cargar cualquier otra vista.
  - Implementar la lógica de comprobación de sesión mediante el cliente HTTP `DioClient` y el almacenamiento seguro.

- [ ] **T03 — Gestión Limpia del Cierre de Sesión (Logout)**
  - Programar la función de Logout en el gestor de estado (State Management) de la app.
  - Limpiar el almacenamiento y asegurar la redirección sin historial al login para evitar vulnerabilidades de navegación.