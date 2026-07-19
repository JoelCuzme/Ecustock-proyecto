async function createUser(pool, user) {
  let conn;
  try {
    conn = await pool.getConnection();
    const query = `
      INSERT INTO usuarios (nombre, email, password_hash, rol, sede)
      VALUES (?, ?, ?, ?, ?)
    `;
    const params = [
      user.nombre,
      user.email,
      user.password_hash,
      user.rol,
      user.sede || null,
    ];
    const result = await conn.query(query, params);
    return { insertId: result.insertId };
  } finally {
    if (conn) conn.release();
  }
}

async function getUserByEmail(pool, email) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      'SELECT id, nombre, email, password_hash, rol, sede FROM usuarios WHERE email = ? LIMIT 1',
      [email]
    );
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } finally {
    if (conn) conn.release();
  }
}

async function getUserById(pool, id) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      'SELECT id, nombre, email, rol, sede FROM usuarios WHERE id = ? LIMIT 1',
      [id]
    );
    return Array.isArray(rows) && rows.length > 0 ? rows[0] : null;
  } finally {
    if (conn) conn.release();
  }
}

async function getAllUsers(pool) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      'SELECT id AS id_usuario, nombre, email AS correo, rol FROM usuarios'
    );
    return Array.isArray(rows) ? rows : [];
  } finally {
    if (conn) conn.release();
  }
}

async function updateUserRole(pool, id, rol) {
  let conn;
  try {
    conn = await pool.getConnection();
    const result = await conn.query(
      'UPDATE usuarios SET rol = ? WHERE id = ?',
      [rol, id]
    );
    return result;
  } finally {
    if (conn) conn.release();
  }
}

module.exports = {
  createUser,
  getUserByEmail,
  getUserById,
  getAllUsers,
  updateUserRole,
};
