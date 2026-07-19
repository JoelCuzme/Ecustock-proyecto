/**
 * Modelo ligero para la tabla `productos`.
 * Cada función recibe el pool de conexiones (req.app.locals.db) para obtener conexión.
 */

async function createProduct(pool, product) {
  let conn;
  try {
    conn = await pool.getConnection();
    const query = `
      INSERT INTO productos (codigo_barras, nombre, descripcion, precio_venta, stock_actual, stock_minimo)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    const params = [
      product.codigo_barras || null,
      product.nombre,
      product.descripcion || null,
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
  updateProduct,
  deleteProduct,
};
