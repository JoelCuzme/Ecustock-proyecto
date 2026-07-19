function requireRoles(allowedRoles) {
  return (req, res, next) => {
    const userRole = req.user?.rol;
    if (!userRole || !allowedRoles.includes(userRole)) {
      const err = new Error('Acceso prohibido');
      err.statusCode = 403;
      return next(err);
    }
    return next();
  };
}

function requirePermission(permissionName) {
  return (req, res, next) => {
    const permissions = Array.isArray(req.user?.permisos) ? req.user.permisos : [];
    if (!permissions.includes(permissionName)) {
      const err = new Error('Acceso prohibido');
      err.statusCode = 403;
      return next(err);
    }
    return next();
  };
}

module.exports = {
  requireRoles,
  requirePermission,
};
