const productoModel = require('../models/productoModel');

function formatError(name, message, statusCode = 400, details) {
  const err = new Error(message);
  err.name = name;
  err.statusCode = statusCode;
  if (details) err.details = details;
  return err;
}

const cacheService = require('../services/cacheService');
const productModel = require('../models/productoModel'); // <-- Declaración 2 (Línea 12, duplicada) ❌
async function obtenerProductos(req, res, next) {
  try {
    // 1. Intentar obtener los productos del caché primero
    const cachedProducts = cacheService.get('productList');

    if (cachedProducts) {
      // ¡Cache Hit! Devolvemos los datos directamente desde el caché
      return res.json({ 
        success: true, 
        source: 'cache', 
        products: cachedProducts 
      });
    }

    // 2. Cache Miss: Si no están en caché, consultamos la base de datos
    const pool = req.app.locals.db;
    const products = await productModel.getAllProducts(pool);

    // 3. Guardar el resultado en caché por 5 minutos (300 segundos) para la siguiente consulta
    cacheService.set('productList', products, 300);

    // 4. Responder indicando que la fuente fue la Base de Datos ('db')
    return res.json({ 
      success: true, 
      source: 'db', 
      products 
    });

  } catch (error) { 
    next(error); 
  }
}

// Asegúrate de que esté exportada correctamente abajo (normalmente al final del archivo)
module.exports = {
  // ... tus otros métodos,
  obtenerProductos,
};

async function obtenerProductoPorId(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      throw formatError('InvalidParameter', 'El id del producto debe ser un entero positivo', 400);
    }
    const product = await productoModel.getProductById(pool, id);
    if (!product) {
      throw formatError('NotFound', 'Producto no encontrado', 404);
    }
    return res.json({ success: true, product });
  } catch (error) {
    next(error);
  }
}

async function crearProducto(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const { codigo_barras, nombre, descripcion, precio_venta, stock_actual, stock_minimo } = req.body;

    if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
      throw formatError('ValidationError', 'El nombre es requerido', 400);
    }
    if (precio_venta === undefined || isNaN(Number(precio_venta)) || Number(precio_venta) < 0) {
      throw formatError('ValidationError', 'precio_venta debe ser un número >= 0', 400);
    }

    const parsedStockActual = stock_actual !== undefined ? Number(stock_actual) : undefined;
    const parsedStockMinimo = stock_minimo !== undefined ? Number(stock_minimo) : undefined;

    if (parsedStockActual !== undefined && (!Number.isInteger(parsedStockActual) || parsedStockActual < 0)) {
      throw formatError('ValidationError', 'stock_actual debe ser un entero >= 0', 400);
    }
    if (parsedStockMinimo !== undefined && (!Number.isInteger(parsedStockMinimo) || parsedStockMinimo < 0)) {
      throw formatError('ValidationError', 'stock_minimo debe ser un entero >= 0', 400);
    }

    const cleanedCodigoBarras = typeof codigo_barras === 'string' ? codigo_barras.trim() : codigo_barras;
    const cleanedDescripcion = typeof descripcion === 'string' ? descripcion.trim() : descripcion;

    const product = {
      codigo_barras: cleanedCodigoBarras || null,
      nombre: nombre.trim(),
      descripcion: cleanedDescripcion || null,
      precio_venta: Number(precio_venta),
      stock_actual: parsedStockActual !== undefined ? parsedStockActual : 0,
      stock_minimo: parsedStockMinimo !== undefined ? parsedStockMinimo : 5,
    };

    const result = await productoModel.createProduct(pool, product);
    const created = await productoModel.getProductById(pool, result.insertId);

    return res.status(201).json({ success: true, product: created });
  } catch (error) {
    // Duplicate barcode error handling for MariaDB
    if (error && error.code === 'ER_DUP_ENTRY') {
      return next(formatError('DuplicateEntry', 'codigo_barras ya existe', 409));
    }
    next(error);
  }
}

async function actualizarProducto(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      throw formatError('InvalidParameter', 'El id del producto debe ser un entero positivo', 400);
    }

    const { codigo_barras, nombre, descripcion, precio_venta, stock_actual, stock_minimo } = req.body;

    const fields = {};
    if (codigo_barras !== undefined) fields.codigo_barras = codigo_barras;
    if (nombre !== undefined) {
      if (typeof nombre !== 'string' || nombre.trim() === '') {
        throw formatError('ValidationError', 'nombre inválido', 400);
      }
      fields.nombre = nombre.trim();
    }
    if (descripcion !== undefined) fields.descripcion = descripcion;
    if (precio_venta !== undefined) {
      if (isNaN(Number(precio_venta)) || Number(precio_venta) < 0) {
        throw formatError('ValidationError', 'precio_venta debe ser un número >= 0', 400);
      }
      fields.precio_venta = Number(precio_venta);
    }
    if (stock_actual !== undefined) {
      const parsedStockActual = Number(stock_actual);
      if (!Number.isInteger(parsedStockActual) || parsedStockActual < 0) {
        throw formatError('ValidationError', 'stock_actual debe ser un entero >= 0', 400);
      }
      fields.stock_actual = parsedStockActual;
    }
    if (stock_minimo !== undefined) {
      const parsedStockMinimo = Number(stock_minimo);
      if (!Number.isInteger(parsedStockMinimo) || parsedStockMinimo < 0) {
        throw formatError('ValidationError', 'stock_minimo debe ser un entero >= 0', 400);
      }
      fields.stock_minimo = parsedStockMinimo;
    }

    if (Object.keys(fields).length === 0) {
      throw formatError('ValidationError', 'No se proporcionaron campos válidos para actualizar', 400);
    }

    const result = await productoModel.updateProduct(pool, id, fields);
    if (result.affectedRows === 0) {
      throw formatError('NotFound', 'Producto no encontrado', 404);
    }

    const updated = await productoModel.getProductById(pool, id);
    return res.json({ success: true, product: updated });
  } catch (error) {
    if (error && error.code === 'ER_DUP_ENTRY') {
      return next(formatError('DuplicateEntry', 'codigo_barras ya existe', 409));
    }
    next(error);
  }
}

async function eliminarProducto(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      throw formatError('InvalidParameter', 'El id del producto debe ser un entero positivo', 400);
    }

    const result = await productoModel.deleteProduct(pool, id);
    if (result.affectedRows === 0) {
      throw formatError('NotFound', 'Producto no encontrado', 404);
    }

    return res.json({ success: true, message: 'Producto eliminado correctamente' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  obtenerProductos,
  obtenerProductoPorId,
  crearProducto,
  actualizarProducto,
  eliminarProducto,
};
