# # 007 · Manejo de Errores Robusto — Plan

_Estrategia integral para capturar, procesar y reportar errores tanto en el Backend (Node.js/MariaDB) como en el Frontend (Flutter)._

## Enfoque

Implementar un sistema centralizado de gestión de excepciones que evite caídas inesperadas en la aplicación móvil y estandarice las respuestas de error de la API REST. El backend validará los esquemas de datos entrantes de forma estricta y responderá con códigos de estado HTTP precisos (400, 401, 403, 404, 500) y JSON informativos. El frontend interpretará estas respuestas a través del cliente HTTP (`DioClient`) y las presentará al usuario de forma comprensible.

## Implementación

1. **Estandarización del Backend (Node.js)**:
   - Middleware de manejo de errores global (`errorHandler.js`) que intercepte cualquier excepción no controlada en Express.
   - Validación de peticiones con esquemas descriptivos. Si falla, responderá con `400 Bad Request` y la lista exacta de campos con problemas.
   - Formato estándar de respuesta de error:
     ```json
     {
       "error": "Nombre del Error",
       "message": "Mensaje entendible por el usuario",
       "details": []
     }
     ```

2. **Estructura en Flutter**:
   - **`lib/core/errors/exceptions.dart`**: Definición de excepciones personalizadas (ej. `ServerException`, `CacheException`, `NetworkException`).
   - **Manejo en Interceptores**: Actualizar `DioClient` para que capture automáticamente errores de red (como pérdida de señal) y códigos HTTP específicos, mapeándolos a alertas amigables en lugar de crasheos de consola.

## Decisiones

- **Validación del lado del Servidor:** Toda entrada se validará rigurosamente antes de interactuar con MariaDB para evitar errores de restricción de base de datos no controlados.
- **Mensajes Amigables:** Se prohíbe mostrar trazas de error de sistema o código SQL directo al usuario final por motivos de seguridad y experiencia de usuario.

## Riesgos

- **Fugas de Información en Errores:** Enviar trazas de error de base de datos (MariaDB/Express) al cliente de Flutter puede revelar detalles del esquema de la base de datos a atacantes.
  - **Mitigación:** En producción, el backend ocultará la traza técnica (`stack`) del error y solo devolverá un mensaje genérico de error de servidor (500).