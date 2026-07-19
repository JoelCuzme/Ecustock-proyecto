# Plan de Desarrollo: Módulo de Inventario y Productos - EcuStock

Este documento describe el plan para implementar el control de inventario y productos en el backend de EcuStock, asegurando su persistencia en la base de datos MariaDB y su correcta documentación en Swagger.

## Objetivos
1. Crear la tabla `productos` en la base de datos `ecustock`.
2. Implementar el modelo, controlador y rutas en Express para la gestión de productos (CRUD).
3. Asegurar las rutas para que solo usuarios autenticados (con token Bearer JWT) puedan modificar el inventario.
4. Documentar todos los nuevos endpoints en Swagger para que aparezcan en `/api/docs`.

## Fases de Implementación
*   **Fase 1: Base de Datos** -> Ejecutar la migración o script SQL para la tabla de productos.
*   **Fase 2: Backend (Estructura)** -> Crear el modelo de datos, los controladores para cada operación y el archivo de rutas de productos.
*   **Fase 3: Seguridad** -> Integrar el middleware de autenticación JWT a las rutas correspondientes.
*   **Fase 4: Swagger** -> Añadir los bloques de documentación JSDoc en el archivo de rutas de productos.