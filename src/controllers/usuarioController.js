const bcrypt = require('bcryptjs');
const usuarioModel = require('../models/usuarioModel');
const refreshTokenModel = require('../models/refreshTokenModel');
const { addEmailJob } = require('../services/queueService');

function formatError(name, message, statusCode = 400) {
  const err = new Error(message);
  err.name = name;
  err.statusCode = statusCode;
  return err;
}

async function obtenerUsuarios(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const usuarios = await usuarioModel.getAllUsers(pool);
    return res.json({ success: true, usuarios });
  } catch (error) {
    next(error);
  }
}

async function crearUsuario(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const { nombre, correo, password, rol, sede } = req.body;

    if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
      throw formatError('ValidationError', 'El nombre es requerido', 400);
    }
    if (!correo || typeof correo !== 'string' || correo.trim() === '') {
      throw formatError('ValidationError', 'El correo es requerido', 400);
    }
    if (!password || typeof password !== 'string' || password.length < 6) {
      throw formatError('ValidationError', 'La contraseña debe tener al menos 6 caracteres', 400);
    }
    if (!rol || typeof rol !== 'string' || rol.trim() === '') {
      throw formatError('ValidationError', 'El rol es requerido', 400);
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = {
      nombre: nombre.trim(),
      email: correo.trim().toLowerCase(),
      password_hash: passwordHash,
      rol: rol.trim(),
      sede: sede ? sede.toString().trim() : null,
    };

    const result = await usuarioModel.createUser(pool, user);
    const created = await usuarioModel.getUserById(pool, result.insertId);
    
    // Encolar el trabajo de envío de email de bienvenida
    try {
      await addEmailJob('sendWelcomeEmail', { 
        email: created.email, 
        nombre: created.nombre 
      });
    } catch (queueError) {
      console.error(`⚠ Advertencia: Error al encolar el email de bienvenida: ${queueError.message}`);
      // No lanzamos el error, permitimos que la respuesta HTTP se envíe normalmente
    }

    return res.status(201).json({ success: true, usuario: created });
  } catch (error) {
    if (error && error.code === 'ER_DUP_ENTRY') {
      return next(formatError('DuplicateEntry', 'El correo ya está en uso', 409));
    }
    next(error);
  }
}

async function actualizarRolUsuario(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const id = Number(req.params.id);
    const { rol } = req.body;

    if (!Number.isInteger(id) || id <= 0) {
      throw formatError('InvalidParameter', 'El id del usuario debe ser un entero positivo', 400);
    }
    if (!rol || typeof rol !== 'string' || rol.trim() === '') {
      throw formatError('ValidationError', 'El rol es requerido', 400);
    }

    const result = await usuarioModel.updateUserRole(pool, id, rol.trim());
    if (result.affectedRows === 0) {
      throw formatError('NotFound', 'Usuario no encontrado', 404);
    }

    await refreshTokenModel.revokeRefreshTokensByUser(pool, id);

    return res.json({ success: true, message: 'Rol actualizado correctamente' });
  } catch (error) {
    next(error);
  }
}

module.exports = {
  obtenerUsuarios,
  crearUsuario,
  actualizarRolUsuario,
};
