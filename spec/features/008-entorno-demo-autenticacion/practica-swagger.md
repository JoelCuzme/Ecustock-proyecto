# Práctica Autónoma de Autenticación con Swagger

Pasos guiados para validar de forma independiente el backend de EcuStock:

1. Asegúrate de tener el backend encendido con `npm start`.
2. Abre tu navegador en `http://192.168.1.2:3000/api/docs`.
3. Busca la sección **Auth** y despliega el endpoint `POST /auth/login`.
4. Haz clic en **Try it out** y envía un cuerpo JSON de prueba con credenciales válidas creadas en tu base de datos MariaDB.
5. Copia el `"token"` devuelto en la respuesta HTTP 200.
6. Haz clic en el botón de candado (**Authorize**) arriba a la derecha en la página de Swagger, pega el token y pulsa "Authorize".
7. Prueba a consumir endpoints protegidos como `GET /usuarios` para confirmar que se ejecutan correctamente gracias al token cargado en Swagger.
