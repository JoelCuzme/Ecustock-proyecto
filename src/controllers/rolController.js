const rolModel = require('../models/rolModel');

function formatError(name, message, statusCode = 400) {
  const err = new Error(message);
  err.name = name;
  err.statusCode = statusCode;
  return err;
}

async function obtenerRoles(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const roles = await rolModel.getRolesWithPermissions(pool);
    return res.json(roles);
  } catch (error) {
    next(error);
  }
}

async function actualizarPermisosRol(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const roleId = Number(req.params.id);
    const { permisos } = req.body;

    if (!Number.isInteger(roleId) || roleId <= 0) {
      throw formatError('InvalidParameter', 'El id del rol debe ser un entero positivo', 400);
    }
    if (permisos == null || !Array.isArray(permisos)) {
      throw formatError('ValidationError', 'La lista de permisos es requerida', 400);
    }

    const permissionIds = permisos
      .map((item) => Number(item))
      .filter((item) => Number.isInteger(item) && item > 0);

    await rolModel.updateRolePermissions(pool, roleId, permissionIds);
    return res.json({ success: true, message: 'Permisos actualizados correctamente' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  obtenerRoles,
  actualizarPermisosRol,
};
