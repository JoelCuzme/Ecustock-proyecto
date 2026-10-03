const jwt = require('jsonwebtoken');

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization || req.headers.Authorization;

  if (!authHeader || typeof authHeader !== 'string' || !authHeader.startsWith('Bearer ')) {
    const err = new Error('Authorization header missing or malformed');
    err.statusCode = 401;
    return next(err);
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET);
    req.user = {
      id: payload.id,
      email: payload.email,
      nombre: payload.nombre,
      rol: payload.rol ?? null,
      sede: payload.sede ?? null,
      permisos: Array.isArray(payload.permisos) ? payload.permisos : [],
    };
    return next();
  } catch (error) {
    const err = new Error('Token inválido o expirado');
    err.statusCode = 401;
    return next(err);
  }
}

module.exports = authMiddleware;
