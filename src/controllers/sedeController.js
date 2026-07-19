const sedeModel = require('../models/sedeModel');

function formatError(name, message, statusCode = 400) {
  const err = new Error(message);
  err.name = name;
  err.statusCode = statusCode;
  return err;
}

async function obtenerSedes(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const sedes = await sedeModel.getAllSedes(pool);
    return res.json({ success: true, sedes });
  } catch (error) {
    next(error);
  }
}

async function crearSede(req, res, next) {
  try {
    const pool = req.app.locals.db;
    const { nombre, direccion, codigo_establecimiento, id_organizacion } = req.body;

    if (!nombre || typeof nombre !== 'string' || nombre.trim() === '') {
      throw formatError('ValidationError', 'El nombre de la sede es requerido', 400);
    }
    if (!direccion || typeof direccion !== 'string' || direccion.trim() === '') {
      throw formatError('ValidationError', 'La dirección es requerida', 400);
    }
    if (!codigo_establecimiento || typeof codigo_establecimiento !== 'string' || !/^\d{3}$/.test(codigo_establecimiento.trim())) {
      throw formatError('ValidationError', 'El código de establecimiento debe tener exactamente 3 dígitos', 400);
    }

    const sedeData = {
      id_organizacion: id_organizacion && Number.isInteger(Number(id_organizacion))
        ? Number(id_organizacion)
        : 1,
      nombre: nombre.trim(),
      direccion: direccion.trim(),
      codigo_establecimiento: codigo_establecimiento.trim(),
    };

    const result = await sedeModel.createSede(pool, sedeData);
    const created = await sedeModel.getAllSedes(pool); // reuse list after insert

    return res.status(201).json({ success: true, sedes: created });
  } catch (error) {
    if (error && error.code === 'ER_DUP_ENTRY') {
      return next(formatError('DuplicateEntry', 'El código de establecimiento ya existe', 409));
    }
    next(error);
  }
}

module.exports = {
  obtenerSedes,
  crearSede,
};
