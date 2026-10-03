/**
 * Modelo ligero para la tabla `productos`.
 * Cada función recibe el pool de conexiones (req.app.locals.db) para obtener conexión.
 */

async function createProduct(pool, product) {
  let conn;
  try {
    conn = await pool.getConnection();
    const query = `
      INSERT INTO productos (
        codigo_barras, nombre, descripcion, precio_costo, precio_venta, stock_actual, stock_minimo
      )
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    const params = [
      product.codigo_barras || null,
      product.nombre,
      product.descripcion || null,
      product.precio_costo,
      product.precio_venta,
      product.stock_actual !== undefined ? product.stock_actual : 0,
      product.stock_minimo !== undefined ? product.stock_minimo : 5,
    ];
    const result = await conn.query(query, params);
    return { insertId: result.insertId };
  } finally {
    if (conn) conn.release();
  }
}

async function getAllProducts(pool) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query('SELECT * FROM productos');
    return Array.isArray(rows) ? rows : [];
  } finally {
    if (conn) conn.release();
  }
}

async function getProductById(pool, id) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query('SELECT * FROM productos WHERE id = ?', [id]);
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } finally {
    if (conn) conn.release();
  }
}

async function getProductByBarcode(pool, codigoBarras) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      'SELECT * FROM productos WHERE codigo_barras = ?',
      [codigoBarras],
    );
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } finally {
    if (conn) conn.release();
  }
}

async function registerStockMovement(pool, id, type, quantity) {
  let conn;
  let transactionStarted = false;
  try {
    conn = await pool.getConnection();
    await conn.beginTransaction();
    transactionStarted = true;

    const rows = await conn.query(
      'SELECT * FROM productos WHERE id = ? FOR UPDATE',
      [id],
    );
    if (!Array.isArray(rows) || rows.length === 0) {
      const error = new Error('Producto no encontrado');
      error.statusCode = 404;
      throw error;
    }
    if (rows[0].precio_costo == null) {
      const error = new Error(
        'Debe completar precio_costo antes de registrar movimientos de inventario.',
      );
      error.statusCode = 400;
      throw error;
    }

    const currentStock = Number(rows[0].stock_actual);
    const nextStock =
      type === 'ingreso' ? currentStock + quantity : currentStock - quantity;
    if (nextStock < 0) {
      const error = new Error('Stock insuficiente para registrar el egreso.');
      error.statusCode = 409;
      throw error;
    }

    await conn.query(
      'UPDATE productos SET stock_actual = ? WHERE id = ?',
      [nextStock, id],
    );
    await conn.commit();
    transactionStarted = false;

    return { ...rows[0], stock_actual: nextStock };
  } catch (error) {
    if (transactionStarted) {
      try {
        await conn.rollback();
      } catch (rollbackError) {
        throw new AggregateError(
          [error, rollbackError],
          'Falló la operación de inventario y también su reversión.',
        );
      }
    }
    throw error;
  } finally {
    if (conn) conn.release();
  }
}

async function updateProduct(pool, id, fields) {
  let conn;
  try {
    conn = await pool.getConnection();
    const sets = [];
    const params = [];

    if (fields.codigo_barras !== undefined) {
      sets.push('codigo_barras = ?');
      params.push(fields.codigo_barras);
    }
    if (fields.nombre !== undefined) {
      sets.push('nombre = ?');
      params.push(fields.nombre);
    }
    if (fields.descripcion !== undefined) {
      sets.push('descripcion = ?');
      params.push(fields.descripcion);
    }
    if (fields.precio_costo !== undefined) {
      sets.push('precio_costo = ?');
      params.push(fields.precio_costo);
    }
    if (fields.precio_venta !== undefined) {
      sets.push('precio_venta = ?');
      params.push(fields.precio_venta);
    }
    if (fields.stock_actual !== undefined) {
      sets.push('stock_actual = ?');
      params.push(fields.stock_actual);
    }
    if (fields.stock_minimo !== undefined) {
      sets.push('stock_minimo = ?');
      params.push(fields.stock_minimo);
    }

    if (sets.length === 0) {
      return { affectedRows: 0 };
    }

    params.push(id);
    const query = `UPDATE productos SET ${sets.join(', ')} WHERE id = ?`;
    const result = await conn.query(query, params);
    return result;
  } finally {
    if (conn) conn.release();
  }
}

async function deleteProduct(pool, id) {
  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.query('DELETE FROM productos WHERE id = ?', [id]);
    return result;
  } finally {
    if (conn) conn.release();
  }
}

module.exports = {
  createProduct,
  getAllProducts,
  getProductById,
  getProductByBarcode,
  registerStockMovement,
  updateProduct,
  deleteProduct,
};
