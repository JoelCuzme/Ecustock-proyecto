# Tareas Pendientes: Módulo de Productos

Por favor, ejecuta las siguientes tareas en orden para completar el módulo:

- [ ] **Tarea 1: Base de Datos**
      Crea el script de migración SQL o ejecuta el query correspondiente en la base de datos `ecustock` para crear la tabla `productos` con los campos definidos en `spec.md`.

- [ ] **Tarea 2: Modelo y Conexión**
      Crea el archivo de modelo (por ejemplo, en `src/models/producto.js` o como esté estructurado tu proyecto) para mapear las operaciones de la base de datos mediante tu pool de conexiones a MariaDB.

- [ ] **Tarea 3: Controlador de Productos**
      Crea `src/controllers/productoController.js` e implementa las funciones CRUD: `obtenerProductos`, `obtenerProductoPorId`, `crearProducto`, `actualizarProducto` y `eliminarProducto`.

- [ ] **Tarea 4: Rutas y Seguridad**
      Crea el archivo `src/routes/productos.js`. Importa el controlador y asocia cada ruta a su función correspondiente. Asegura las rutas utilizando el middleware de verificación de JWT (el mismo que usa `/api/v1/auth/me`).

- [ ] **Tarea 5: Registro de Rutas en la App**
      Importa y activa el nuevo enrutador de productos en tu archivo principal `src/app.js` usando el prefijo `/api/v1/productos`.

- [ ] **Tarea 6: Documentación en Swagger**
      Escribe los comentarios JSDoc (OpenAPI/OAS 3.0) correspondientes en `src/routes/productos.js` para que Swagger lea e interactúe con los nuevos endpoints de inventario, incluyendo el candado de seguridad JWT (`BearerAuth`).
