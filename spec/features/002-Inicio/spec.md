# # 002 · Autenticación Core (Login JWT) — Especificación

_Definición funcional y técnica del flujo de inicio de sesión de EcuStock._[cite: 1]

## Casos de Uso

1. **Login de Usuario:** El usuario ingresa su correo electrónico y contraseña[cite: 1]. El sistema valida sus datos en la base de datos de MariaDB y le da acceso a la aplicación asignándole su rol correspondiente[cite: 1].
2. **Manejo de Sesión Activa:** La aplicación recuerda al usuario para que no tenga que ingresar sus credenciales cada vez que abra la aplicación, haciendo uso seguro de los tokens[cite: 1].
3. **Cierre de Sesión:** El usuario decide salir, por lo que se eliminan de manera local y segura todas sus credenciales y tokens guardados en el dispositivo[cite: 1].

## Diseño de Pantalla (Formulario)
- **Input Correo:** Campo de texto con validación de patrón de e-mail.
- **Input Contraseña:** Campo de texto oculto con botón de visualización de contraseña (ojo).
- **Botón Ingresar:** Desencadena el evento de login con estado de indicador de carga circular.

## Arquitectura de Archivos (Flutter)
- `lib/core/network/auth_secure_storage.dart` -> Servicio de encriptación de credenciales[cite: 1].
- `lib/core/network/dio_client.dart` -> Interceptor de red para adjuntar tokens y refresco silencioso de expiración[cite: 1].
- `lib/presentation/screens/login_screen.dart` -> UI de Login[cite: 1].