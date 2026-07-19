# # 008 · Entorno Demo Autenticación — Tareas

_Checklist de desarrollo e integración de seguridad para EcuStock._

## Tareas

- [ ] **T01 — Endpoint de Generación de Token en Node.js**
  - Implementar la lógica de autenticación en el router de Express validando contra MariaDB.
  - Generar el JWT firmado y configurar su documentación interactiva en Swagger.

- [ ] **T02 — Persistencia del Token en Flutter**
  - Configurar un paquete de almacenamiento seguro en el dispositivo móvil.
  - Almacenar el token al iniciar sesión y limpiarlo al cerrar sesión.

- [ ] **T03 — Interceptor de Autorización Bearer**
  - Modificar el `DioClient` para que recupere el token del almacenamiento seguro y lo añada al encabezado de las llamadas API de forma transparente.