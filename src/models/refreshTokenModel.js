async function insertRefreshToken(pool, userId, token, expiresAt) {
  let conn;
  try {
    conn = await pool.getConnection();
    const query = `
      INSERT INTO refresh_tokens (user_id, token, expires_at)
      VALUES (?, ?, ?)
    `;
    const params = [userId, token, expiresAt];
    const result = await conn.query(query, params);
    return { insertId: result.insertId };
  } finally {
    if (conn) conn.release();
  }
}

async function findValidRefreshToken(pool, token) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      `SELECT id, user_id, token, revoked, expires_at FROM refresh_tokens WHERE token = ? LIMIT 1`,
      [token]
    );
    if (!Array.isArray(rows) || rows.length === 0) {
      return null;
    }
    return rows[0];
  } finally {
    if (conn) conn.release();
  }
}

async function revokeRefreshToken(pool, token) {
  let conn;
  try {
    conn = await pool.getConnection();
    return await conn.query(
      `UPDATE refresh_tokens SET revoked = TRUE WHERE token = ?`,
      [token]
    );
  } finally {
    if (conn) conn.release();
  }
}

async function revokeRefreshTokensByUser(pool, userId) {
  let conn;
  try {
    conn = await pool.getConnection();
    return await conn.query(
      `UPDATE refresh_tokens SET revoked = TRUE WHERE user_id = ?`,
      [userId]
    );
  } finally {
    if (conn) conn.release();
  }
}

module.exports = {
  insertRefreshToken,
  findValidRefreshToken,
  revokeRefreshToken,
  revokeRefreshTokensByUser,
};
