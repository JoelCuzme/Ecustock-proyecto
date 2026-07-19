# Especificación Técnica: Gestión de Productos

## 1. Modelo de Datos (Tabla `productos`)
La tabla debe crearse en MariaDB con los siguientes campos:
*   `id`: INT AUTO_INCREMENT PRIMARY KEY.
*   `codigo_barras`: VARCHAR(50) UNIQUE (opcional, para lectura en la app móvil).
*   `nombre`: VARCHAR(100) NOT NULL.
*   `descripcion`: TEXT.
*   `precio_venta`: DECIMAL(10, 2) NOT NULL.
*   `stock_actual`: INT NOT NULL DEFAULT 0.
*   `stock_minimo`: INT DEFAULT 5 (para alertas de stock bajo).
*   `created_at` / `updated_at`: TIMESTAMP automáticos.

## 2. Endpoints Requeridos (`/api/v1/productos`)

| Método | Endpoint | Descripción | Requiere Auth |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/productos` | Obtener lista de todos los productos | Sí |
| **GET** | `/api/v1/productos/:id` | Obtener detalles de un producto específico | Sí |
| **POST** | `/api/v1/productos` | Registrar un nuevo producto en el inventario | Sí |
| **PUT** | `/api/v1/productos/:id` | Actualizar datos o stock de un producto | Sí |
| **DELETE** | `/api/v1/productos/:id`| Eliminar un producto del sistema | Sí |

## 3. Reglas de Negocio
*   El `precio_venta` no puede ser negativo.
*   El `stock_actual` no puede actualizarse a un número menor a cero.
*   Todas las respuestas de error deben seguir el formato JSON estándar del proyecto: `{"error": "NombreError", "message": "Detalle del error"}`.