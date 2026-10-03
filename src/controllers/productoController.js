const cacheService = require('../services/cacheService');
const productoModel = require('../models/productoModel');

function formatError(name, message, statusCode = 400) {
  const error = new Error(message);
  error.name = name;
  error.statusCode = statusCode;
  return error;
}

function validateBarcode(value) {
  return typeof value === 'string' && /^\d{8,14}$/.test(value);
}

function validateProductName(value) {
  if (typeof value !== 'string') return false;
  const characterCount = Array.from(value.trim()).length;
  return characterCount >= 3 && characterCount <= 100;
}

function parsePositivePrice(value) {
  const price = Number(value);
  return Number.isFinite(price) && price > 0 ? price : null;
}

async function obtenerProductos(req, res, next) {
  try {
    const cachedProducts = cacheService.get('productList');

    if (cachedProducts) {
      return res.json({ success: true, source: 'cache', products: cachedProducts });
    }

    const pool = req.app.locals.db;
    const products = await productoModel.getAllProducts(pool);
    cacheService.set('productList', products, 300);

    return res.json({ success: true, source: 'db', products });
  } catch (error) {
    next(error);
  }
}

async function obtenerProductoPorId(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      throw formatError('InvalidParameter', 'El id del producto debe ser un entero positivo');
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

async function obtenerProductoPorCodigo(req, res, next) {
  try {
    const codigoBarras = req.params.codigoBarras;
    if (!validateBarcode(codigoBarras)) {
      throw formatError(
        'ValidationError',
        'codigo_barras debe contener entre 8 y 14 dígitos.',
      );
    }

    const product = await productoModel.getProductByBarcode(
      req.app.locals.db,
      codigoBarras,
    );
    if (!product) {
      throw formatError('NotFound', 'No se localizó el producto para ese código.', 404);
    }

    return res.json({ success: true, product });
  } catch (error) {
    next(error);
  }
}

async function registrarMovimientoStock(req, res, next) {
  try {
    const id = Number(req.params.id);
    const { tipo, cantidad } = req.body ?? {};
    const parsedQuantity = Number(cantidad);
    if (!Number.isInteger(id) || id <= 0) {
      throw formatError(
        'InvalidParameter',
        'El id del producto debe ser un entero positivo.',
      );
    }
    if (tipo !== 'ingreso' && tipo !== 'egreso') {
      throw formatError('ValidationError', 'tipo debe ser ingreso o egreso.');
    }
    if (!Number.isInteger(parsedQuantity) || parsedQuantity <= 0) {
      throw formatError(
        'ValidationError',
        'cantidad debe ser un entero mayor que cero.',
      );
    }

    const product = await productoModel.registerStockMovement(
      req.app.locals.db,
      id,
      tipo,
      parsedQuantity,
    );
    return res.json({ success: true, product });
  } catch (error) {
    next(error);
  }
}

async function crearProducto(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const {
      codigo_barras,
      nombre,
      descripcion,
      precio_costo,
      precio_venta,
      stock_actual,
      stock_minimo,
    } = req.body ?? {};

    const cleanedCodigoBarras =
      typeof codigo_barras === 'string' ? codigo_barras.trim() : codigo_barras;
    if (!validateBarcode(cleanedCodigoBarras)) {
      throw formatError('ValidationError', 'codigo_barras debe contener entre 8 y 14 dígitos.');
    }
    if (!validateProductName(nombre)) {
      throw formatError('ValidationError', 'nombre debe tener entre 3 y 100 caracteres.');
    }

    const parsedPrecioCosto = parsePositivePrice(precio_costo);
    const parsedPrecioVenta = parsePositivePrice(precio_venta);
    if (parsedPrecioCosto === null) {
      throw formatError('ValidationError', 'precio_costo debe ser mayor que cero.');
    }
    if (parsedPrecioVenta === null || parsedPrecioVenta <= parsedPrecioCosto) {
      throw formatError(
        'ValidationError',
        'precio_venta debe ser mayor que precio_costo.',
      );
    }

    const parsedStockActual = stock_actual !== undefined ? Number(stock_actual) : undefined;
    const parsedStockMinimo = stock_minimo !== undefined ? Number(stock_minimo) : undefined;

    if (parsedStockActual !== undefined && (!Number.isInteger(parsedStockActual) || parsedStockActual < 0)) {
      throw formatError('ValidationError', 'stock_actual debe ser un entero >= 0.');
    }
    if (parsedStockMinimo !== undefined && (!Number.isInteger(parsedStockMinimo) || parsedStockMinimo < 0)) {
      throw formatError('ValidationError', 'stock_minimo debe ser un entero >= 0.');
    }

    const cleanedDescripcion = typeof descripcion === 'string' ? descripcion.trim() : descripcion;

    const product = {
      codigo_barras: cleanedCodigoBarras,
      nombre: nombre.trim(),
      descripcion: cleanedDescripcion || null,
      precio_costo: parsedPrecioCosto,
      precio_venta: parsedPrecioVenta,
      stock_actual: parsedStockActual !== undefined ? parsedStockActual : 0,
      stock_minimo: parsedStockMinimo !== undefined ? parsedStockMinimo : 5,
    };

    const result = await productoModel.createProduct(pool, product);
    const created = await productoModel.getProductById(pool, result.insertId);

    return res.status(201).json({ success: true, product: created });
  } catch (error) {
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

    const {
      codigo_barras,
      nombre,
      descripcion,
      precio_costo,
      precio_venta,
      stock_actual,
      stock_minimo,
    } = req.body ?? {};

    const currentProduct = await productoModel.getProductById(pool, id);
    if (!currentProduct) {
      throw formatError('NotFound', 'Producto no encontrado', 404);
    }

    const fields = {};
    if (codigo_barras !== undefined) {
      const cleanedCodigoBarras =
        typeof codigo_barras === 'string' ? codigo_barras.trim() : codigo_barras;
      if (!validateBarcode(cleanedCodigoBarras)) {
        throw formatError('ValidationError', 'codigo_barras debe contener entre 8 y 14 dígitos.');
      }
      fields.codigo_barras = cleanedCodigoBarras;
    } else if (!validateBarcode(currentProduct.codigo_barras)) {
      throw formatError('ValidationError', 'Debe completar un codigo_barras válido.');
    }

    if (nombre !== undefined) {
      if (!validateProductName(nombre)) {
        throw formatError('ValidationError', 'nombre debe tener entre 3 y 100 caracteres.');
      }
      fields.nombre = nombre.trim();
    }
    if (descripcion !== undefined) fields.descripcion = descripcion;
    if (precio_costo !== undefined) {
      const parsedPrecioCosto = parsePositivePrice(precio_costo);
      if (parsedPrecioCosto === null) {
        throw formatError('ValidationError', 'precio_costo debe ser mayor que cero.');
      }
      fields.precio_costo = parsedPrecioCosto;
    }
    if (precio_venta !== undefined) {
      const parsedPrecioVenta = parsePositivePrice(precio_venta);
      if (parsedPrecioVenta === null) {
        throw formatError('ValidationError', 'precio_venta debe ser mayor que cero.');
      }
      fields.precio_venta = parsedPrecioVenta;
    }
    const nextPrecioCosto =
      fields.precio_costo ?? parsePositivePrice(currentProduct.precio_costo);
    const nextPrecioVenta =
      fields.precio_venta ?? parsePositivePrice(currentProduct.precio_venta);
    if (nextPrecioCosto === null) {
      throw formatError(
        'ValidationError',
        'Debe completar precio_costo antes de actualizar este producto.',
      );
    }
    if (nextPrecioVenta === null || nextPrecioVenta <= nextPrecioCosto) {
      throw formatError(
        'ValidationError',
        'precio_venta debe ser mayor que precio_costo.',
      );
    }

    if (stock_actual !== undefined) {
      const parsedStockActual = Number(stock_actual);
      if (!Number.isInteger(parsedStockActual) || parsedStockActual < 0) {
        throw formatError('ValidationError', 'stock_actual debe ser un entero >= 0.');
      }
      fields.stock_actual = parsedStockActual;
    }
    if (stock_minimo !== undefined) {
      const parsedStockMinimo = Number(stock_minimo);
      if (!Number.isInteger(parsedStockMinimo) || parsedStockMinimo < 0) {
        throw formatError('ValidationError', 'stock_minimo debe ser un entero >= 0.');
      }
      fields.stock_minimo = parsedStockMinimo;
    }

    if (Object.keys(fields).length === 0) {
      throw formatError('ValidationError', 'No se proporcionaron campos válidos para actualizar.');
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
  obtenerProductoPorCodigo,
  registrarMovimientoStock,
  crearProducto,
  actualizarProducto,
  eliminarProducto,
};
