# # 008 · Entorno Demo Autenticación — Especificación

_Definición funcional de las pruebas interactivas y flujos de sesión del usuario en EcuStock._

## Casos de Uso

1. **Login Exitoso en la App:**
   - El usuario ingresa credenciales correctas.
   - El sistema almacena el token de sesión y lo redirige a la pantalla principal sin parpadeos.

2. **Persistencia de Sesión:**
   - Si el usuario cierra y vuelve a abrir la app, no se le debe solicitar contraseña nuevamente a menos que su token haya expirado o haya cerrado sesión manualmente.

3. **Prueba de Conectividad con Swagger:**
   - Uso de la documentación interactiva en `/api/docs` para simular llamadas al sistema y validar que las credenciales de prueba devuelvan un estado HTTP 200 y el formato de token correcto.