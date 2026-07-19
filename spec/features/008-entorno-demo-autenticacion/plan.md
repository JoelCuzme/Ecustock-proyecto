# # 008 · Entorno Demo Autenticación — Plan

_Plan de despliegue y pruebas interactivas para el flujo de inicio de sesión y persistencia de sesiones en EcuStock._

## Enfoque

Garantizar que el sistema de autenticación basado en JWT (JSON Web Tokens) funcione correctamente de extremo a extremo. El backend validará las credenciales contra MariaDB, firmará el token de acceso y el frontend de Flutter lo almacenará localmente de forma segura para mantener la sesión activa, incluso si el usuario cierra la aplicación.

## Implementación

1. **Backend (Node.js/Express)**:
   - Configuración de un endpoint `POST /api/v1/auth/login` que valide el correo y contraseña del usuario.
   - Generación de un token JWT firmado con una clave secreta que expire en un tiempo prudencial (ej. 24 horas).
   - Documentación interactiva del flujo en Swagger para pruebas rápidas de credenciales.

2. **Frontend (Flutter)**:
   - Implementación de almacenamiento local seguro (ej. `flutter_secure_storage` o similar) para resguardar el JWT.
   - Interceptor en `DioClient` para inyectar automáticamente el header `Authorization: Bearer <token>` en todas las peticiones que requieran login.
   - Lógica de redirección inicial: si hay un token válido guardado, enviar al usuario directamente al Home; de lo contrario, mostrar la pantalla de Login.