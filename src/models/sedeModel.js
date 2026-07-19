async function getAllSedes(pool) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      'SELECT id_sede, id_organizacion, nombre, direccion, codigo_establecimiento FROM sedes'
    );
    return Array.isArray(rows) ? rows : [];
  } finally {
    if (conn) conn.release();
  }
}

async function createSede(pool, sede) {
  let conn;
  try {
    conn = await pool.getConnection();
    const query = `
      INSERT INTO sedes (id_organizacion, nombre, direccion, codigo_establecimiento)
      VALUES (?, ?, ?, ?)
    `;
    const params = [
      sede.id_organizacion,
      sede.nombre,
      sede.direccion,
      sede.codigo_establecimiento,
    ];
    const result = await conn.query(query, params);
    return { insertId: result.insertId };
  } finally {
    if (conn) conn.release();
  }
}

module.exports = {
  getAllSedes,
  createSede,
};
