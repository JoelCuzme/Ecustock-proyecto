async function getRolesWithPermissions(pool) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      `
      SELECT r.id_rol, r.nombre AS nombre_rol, r.descripcion AS rol_descripcion,
        p.id_permiso, p.nombre AS permiso_nombre, p.descripcion AS permiso_descripcion
      FROM roles r
      LEFT JOIN rol_permiso rp ON rp.id_rol = r.id_rol
      LEFT JOIN permisos p ON p.id_permiso = rp.id_permiso
      ORDER BY r.id_rol, p.id_permiso
      `
    );
    const roles = [];
    const roleMap = new Map();

    for (const row of rows) {
      const roleId = row.id_rol;
      if (!roleMap.has(roleId)) {
        const role = {
          id_rol: roleId,
          nombre: row.nombre_rol,
          descripcion: row.rol_descripcion,
          permisos: [],
        };
        roleMap.set(roleId, role);
        roles.push(role);
      }

      if (row.id_permiso != null) {
        roleMap.get(roleId).permisos.push({
          id_permiso: row.id_permiso,
          nombre: row.permiso_nombre,
          descripcion: row.permiso_descripcion,
        });
      }
    }

    return roles;
  } finally {
    if (conn) conn.release();
  }
}

async function updateRolePermissions(pool, roleId, permissionIds) {
  let conn;
  try {
    conn = await pool.getConnection();
    await conn.query('START TRANSACTION');
    await conn.query('DELETE FROM rol_permiso WHERE id_rol = ?', [roleId]);

    if (permissionIds.length > 0) {
      const inserts = permissionIds
        .map(() => '(?, ?)')
        .join(', ');
      const params = [];
      for (const permisoId of permissionIds) {
        params.push(roleId, permisoId);
      }
      await conn.query(
        `INSERT INTO rol_permiso (id_rol, id_permiso) VALUES ${inserts}`,
        params
      );
    }

    await conn.query('COMMIT');
    return { success: true };
  } catch (error) {
    if (conn) {
      try {
        await conn.query('ROLLBACK');
      } catch (_) {}
    }
    throw error;
  } finally {
    if (conn) conn.release();
  }
}

async function getPermissionsForRole(pool, roleName) {
  let conn;
  try {
    conn = await pool.getConnection();
    const rows = await conn.query(
      `
      SELECT p.nombre AS permiso_nombre
      FROM permisos p
      JOIN rol_permiso rp ON rp.id_permiso = p.id_permiso
      JOIN roles r ON r.id_rol = rp.id_rol
      WHERE r.nombre = ?
      ORDER BY p.id_permiso
      `,
      [roleName]
    );

    if (!Array.isArray(rows)) {
      return [];
    }

    return rows.map((row) => row.permiso_nombre).filter(Boolean);
  } finally {
    if (conn) conn.release();
  }
}

module.exports = {
  getRolesWithPermissions,
  updateRolePermissions,
  getPermissionsForRole,
};
