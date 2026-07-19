const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const authMiddleware = require('../middleware/authMiddleware');
const usuarioModel = require('../models/usuarioModel');
const rolModel = require('../models/rolModel');
const refreshTokenModel = require('../models/refreshTokenModel');

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'mi_secreto_jwt';
const ACCESS_TOKEN_EXPIRES = process.env.JWT_ACCESS_EXPIRATION || '15m';
const REFRESH_TOKEN_EXPIRES = process.env.JWT_REFRESH_EXPIRATION || '7d';
const REFRESH_TOKEN_EXPIRY_MS = 7 * 24 * 60 * 60 * 1000;

function createAccessToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRES });
}

function createRefreshToken(payload) {
  return jwt.sign({ ...payload, type: 'refresh' }, JWT_SECRET, {
    expiresIn: REFRESH_TOKEN_EXPIRES,
  });
}

function formatAuthUser(user, permissions) {
  return {
    id: user.id,
    nombre: user.nombre,
    email: user.email,
    rol: user.rol ?? null,
    sede: user.sede ?? null,
    permisos: permissions,
  };
}

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: Endpoints de autenticación
 */

/**
 * @openapi
 * /api/v1/auth/login:
 *   post:
 *     summary: Iniciar sesión
 *     tags:
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: usuario@ecustock.com
 *               password:
 *                 type: string
 *                 example: demo1234
 *     responses:
 *       200:
 *         description: Inicio de sesión exitoso
 */
router.post('/login', async (req, res, next) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email y contraseña son requeridos' });
  }

  const pool = req.app.locals.db;

  try {
    const user = await usuarioModel.getUserByEmail(pool, email.trim().toLowerCase());
    if (!user) {
      return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);
    if (!passwordMatches) {
      return res.status(401).json({ success: false, message: 'Credenciales inválidas' });
    }

    const permisos = await rolModel.getPermissionsForRole(pool, user.rol);
    const authUser = formatAuthUser(user, permisos);
    const token = createAccessToken(authUser);
    const refreshToken = createRefreshToken({ id: user.id, email: user.email });
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY_MS);

    await refreshTokenModel.insertRefreshToken(pool, user.id, refreshToken, expiresAt);

    res.json({
      success: true,
      token,
      refreshToken,
      user: authUser,
    });
  } catch (error) {
    return next(error);
  }
});

/**
 * @openapi
 * /api/v1/auth/refresh:
 *   post:
 *     summary: Renovar token de acceso
 *     tags:
 *       - Auth
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               refreshToken:
 *                 type: string
 *             required:
 *               - refreshToken
 *     responses:
 *       200:
 *         description: Token renovado
 */
router.post('/refresh', async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken || typeof refreshToken !== 'string') {
    return res.status(400).json({ success: false, message: 'refreshToken es requerido' });
  }

  const pool = req.app.locals.db;

  try {
    const tokenRecord = await refreshTokenModel.findValidRefreshToken(pool, refreshToken);
    if (!tokenRecord || tokenRecord.revoked) {
      return res.status(401).json({ success: false, message: 'Refresh token inválido o revocado' });
    }

    const now = new Date();
    if (new Date(tokenRecord.expires_at) < now) {
      return res.status(401).json({ success: false, message: 'Refresh token expirado' });
    }

    let payload;
    try {
      payload = jwt.verify(refreshToken, JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ success: false, message: 'Refresh token inválido o expirado' });
    }

    if (payload.type !== 'refresh') {
      return res.status(401).json({ success: false, message: 'Refresh token inválido' });
    }

    const user = await usuarioModel.getUserById(pool, payload.id);
    if (!user) {
      return res.status(401).json({ success: false, message: 'Usuario no encontrado' });
    }

    await refreshTokenModel.revokeRefreshToken(pool, refreshToken);

    const permisos = await rolModel.getPermissionsForRole(pool, user.rol);
    const authUser = formatAuthUser(user, permisos);
    const newAccessToken = createAccessToken(authUser);
    const newRefreshToken = createRefreshToken({ id: user.id, email: user.email });
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRY_MS);
    await refreshTokenModel.insertRefreshToken(pool, user.id, newRefreshToken, expiresAt);

    res.json({ success: true, token: newAccessToken, refreshToken: newRefreshToken, user: authUser });
  } catch (error) {
    return next(error);
  }
});

/**
 * @openapi
 * /api/v1/auth/me:
 *   get:
 *     summary: Obtener datos del usuario autenticado
 *     tags:
 *       - Auth
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Perfil del usuario autenticado
 */
router.get('/me', authMiddleware, async (req, res, next) => {
  try {
    const pool = req.app.locals.db;
    const user = await usuarioModel.getUserById(pool, req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'Usuario no encontrado' });
    }

    const permisos = await rolModel.getPermissionsForRole(pool, user.rol);
    const authUser = formatAuthUser(user, permisos);

    res.json({ success: true, user: authUser });
  } catch (error) {
    return next(error);
  }
});

module.exports = router;
