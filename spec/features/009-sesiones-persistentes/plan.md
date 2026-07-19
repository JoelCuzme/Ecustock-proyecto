# # 009 · Sesiones Persistentes — Plan

_Estrategia para el mantenimiento automático del estado de autenticación y renovación de credenciales en el cliente y servidor._

## Enfoque

Garantizar que los operarios y administradores de EcuStock no tengan que ingresar su correo y contraseña repetidamente cada vez que abren la aplicación para gestionar el inventario o emitir facturas. Implementaremos un flujo de validación automática de sesión que verifique el estado del JWT almacenado localmente contra el backend en Node.js al iniciar la app.

## Implementación

1. **Backend (Node.js/Express/MariaDB)**:
   - Crear un endpoint rápido `GET /api/v1/auth/me` que reciba el token actual, valide que no haya sido revocado o haya expirado, y retorne los datos actualizados del usuario (roles, sede asignada).
   - Opcional: Diseñar lógica de renovación automática de tokens si el token de acceso está cerca de expirar.

2. **Frontend (Flutter)**:
   - **Splash Screen de Validación:** Al abrir la aplicación, un estado de carga inicial (`SplashView`) leerá el token persistido con `StorageService`.
   - Si existe un token, se disparará una petición silenciosa a `/auth/me`.
   - Si la petición es exitosa (HTTP 200), se actualiza el estado global del usuario en la app y se le redirige al Home (Bodega/Facturación).
   - Si falla (HTTP 401) o no hay token, se le redirige limpiamente a la pantalla de Login.