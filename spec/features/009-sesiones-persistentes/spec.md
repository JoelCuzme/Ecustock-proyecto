# # 009 · Sesiones Persistentes — Especificación

_Comportamiento funcional de la persistencia de acceso y manejo de sesiones inactivas en EcuStock._

## Casos de Uso

1. **Apertura de App con Sesión Activa:**
   - El usuario abre EcuStock.
   - Se muestra brevemente una pantalla de carga con el logotipo de la aplicación.
   - El sistema comprueba el token en segundo plano, confirma su validez con el servidor y salta directamente al Dashboard sin pasar por el Login.

2. **Apertura de App con Sesión Expirada:**
   - El usuario abre la app tras varios días de inactividad.
   - El servidor rechaza el token porque ha caducado.
   - La aplicación borra automáticamente el token corrupto/viejo de la memoria interna y muestra la pantalla de inicio de sesión con un mensaje: *"Tu sesión ha expirado, por favor ingresa tus datos nuevamente"*.

3. **Cierre de Sesión Voluntario (Logout):**
   - El usuario pulsa "Cerrar Sesión" en su perfil.
   - La aplicación elimina el JWT del almacenamiento seguro y lo devuelve de inmediato a la pantalla de Login, impidiendo que pueda volver atrás con el botón físico del teléfono.