# # 007 · Manejo de Errores Robusto — Tareas

_Checklist técnico para integrar el control de fallos en EcuStock._

## Tareas

- [ ] **T01 — Diseñar Middleware de Errores en Node.js**
  - Crear e integrar un Middleware centralizado en el Backend para capturar excepciones de Express y MariaDB.
  - Configurar respuestas estandarizadas en formato JSON que contengan código de error y mensaje descriptivo.

- [ ] **T02 — Implementar el Manejo de Excepciones en Flutter**
  - Crear el archivo `lib/core/errors/exceptions.dart`.
  - Configurar en `DioClient` el bloque `onError` del interceptor para transformar excepciones de red en alertas comprensibles.

- [ ] **T03 — Crear Componentes de Interfaz de Error**
  - Diseñar un widget de retroalimentación de error reutilizable para pantallas que requieran recarga de datos.
  - Asegurar que todos los formularios de EcuStock reaccionen dinámicamente a las alertas de validación enviadas por la API REST.