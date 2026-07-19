# # 002 · Autenticación Core (Login JWT) — Plan

_Cómo se implementa lo descrito en la Ficha Técnica de EcuStock. Debe respetar la arquitectura cliente-servidor y el control de roles._[cite: 1]

## Enfoque

Implementar un flujo de autenticación *Stateless* basado en JSON Web Tokens (JWT) utilizando un esquema dual (Access Token de corta duración + Refresh Token de larga duración)[cite: 1]. En el cliente móvil (Flutter), los tokens se almacenan de forma segura mediante encriptación a nivel de hardware con el llavero del dispositivo[cite: 1]. En el backend (API REST conectado a MariaDB), el control de acceso y la auditoría se gestionan mediante Middlewares que decodifican la firma digital del token y validan los roles (Administrativo y Bodega) antes de interactuar con el motor InnoDB[cite: 1].

## Implementación

1. **Variables de entorno** — Definir en el backend las variables necesarias para la firma de tokens (`JWT_SECRET`, `JWT_ACCESS_EXPIRATION`, `JWT_REFRESH_EXPIRATION`) y la conexión segura a la base de datos MariaDB[cite: 1].

2. **`lib/core/network/auth_secure_storage.dart` (Flutter)** — Servicio encargado de encapsular el acceso al llavero físico del teléfono usando `flutter_secure_storage`[cite: 1]:
   - `saveTokens(accessToken, refreshToken)` → Guarda de forma segura ambos tokens[cite: 1].
   - `getAccessToken()` / `getRefreshToken()` → Recupera los tokens para las peticiones o el refresco[cite: 1].
   - `clearTokens()` → Elimina los tokens del almacenamiento (cierre de sesión)[cite: 1].

3. **`lib/core/network/dio_client.dart` (Flutter)** — Configuración del cliente HTTP de `dio` agregando un Interceptor personalizado[cite: 1]:
   - **En peticiones (`onRequest`):** Extrae el `accessToken` de `auth_secure_storage` y lo adjunta automáticamente en la cabecera `Authorization: Bearer <token>`[cite: 1].
   - **En errores (`onError`):** Si el backend responde con un código `401 Unauthorized` (token expirado), el interceptor pausa las solicitudes entrantes, realiza una petición de refresco silenciosa al endpoint `/api/v1/auth/refresh` enviando el `refreshToken`, actualiza los nuevos tokens obtenidos y reintenta de forma transparente la petición original que había fallado[cite: 1].

4. **`backend/middlewares/auth_middleware.js` (Backend)** — Componente intermedio que intercepta las peticiones privadas[cite: 1]:
   - Extrae el token de la cabecera de la petición, valida la firma criptográfica y la fecha de expiración[cite: 1].
   - Si es válido, decodifica el payload del JWT (id_usuario, nombre, rol) y lo adjunta al contexto de la petición[cite: 1]. Si falla, retorna `401 Unauthorized`[cite: 1].

5. **`backend/middlewares/role_middleware.js` (Backend)** — Middleware de autorización que recibe una lista de roles permitidos para la ruta[cite: 1]:
   - Comprueba si el rol extraído del JWT (ej. `role: "Bodega"`) tiene permisos para realizar la acción (ej. un bodeguero no puede acceder a emitir facturas)[cite: 1].
   - Si no cuenta con los permisos necesarios, corta la petición de forma inmediata respondiendo con un código `403 Forbidden`[cite: 1].

6. **`POST /api/v1/auth/login` (Backend)** — Endpoint público que recibe `correo` y `password`[cite: 1]:
   - Valida la existencia del usuario en la tabla `usuarios` de MariaDB y comprueba la contraseña mediante hash seguro (ej. bcrypt)[cite: 1].
   - Genera el par de tokens (Access y Refresh) firmados con el `id_usuario`, `nombre` y `rol` en el payload, y responde con un código `200 OK` enviándolos en formato JSON[cite: 1].

7. **`POST /api/v1/auth/refresh` (Backend)** — Endpoint público que valida la firma del `refreshToken` enviado por la app móvil y, si no ha sido revocado en la base de datos, genera un nuevo `accessToken`[cite: 1].

8. **`lib/presentation/screens/login_screen.dart` (Flutter)** — Interfaz del formulario de inicio de sesión con validaciones locales de campos (correo con formato válido y contraseña obligatoria)[cite: 1]. Maneja los estados visuales de carga, errores de credenciales inválidas y redirección exitosa al menú correspondiente según el rol del usuario[cite: 1].

## Decisiones

- **Esquema de tokens dual (Access/Refresh) vs. Token único de larga duración:** Usar un único token es un riesgo crítico[cite: 1]. Con el esquema dual, el Access Token expira rápido (15 minutos)[cite: 1].
- **Almacenamiento seguro local (`flutter_secure_storage`) vs. SharedPreferences:** Se descarta SharedPreferences porque almacena los datos en texto plano. `flutter_secure_storage` garantiza cifrado AES a nivel de hardware (Keychain en iOS / Keystore en Android)[cite: 1].
- **Validación de roles en el Backend vs. Frontend:** Aunque la interfaz de Flutter oculta botones dinámicamente según el rol, el backend siempre valida estrictamente las peticiones en el servidor para evitar falsificaciones[cite: 1].

## Riesgos

- **Pérdida de conexión en bodega (Modo Offline):** Si el dispositivo pierde la señal de red dentro de la bodega, el cliente de Flutter no podrá realizar el flujo de refresco de tokens ni validar credenciales en el servidor[cite: 1].
  - **Mitigación:** Al iniciar sesión con éxito de forma online, se guarda de manera cifrada el último rol y estado del usuario, permitiendo el ingreso limitado localmente a consultas de persistencia[cite: 1].