const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { requireRoles } = require('../middleware/roleMiddleware');
const usuarioController = require('../controllers/usuarioController');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Usuarios
 *   description: Endpoints para la gestión de usuarios
 */

/**
 * @openapi
 * /api/v1/usuarios:
 *   get:
 *     summary: Obtener lista de usuarios
 *     tags:
 *       - Usuarios
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de usuarios
 */
router.get('/', authMiddleware, requireRoles(['Administrativo']), usuarioController.obtenerUsuarios);

/**
 * @openapi
 * /api/v1/usuarios:
 *   post:
 *     summary: Crear un nuevo usuario
 *     tags:
 *       - Usuarios
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nombre:
 *                 type: string
 *               correo:
 *                 type: string
 *               password:
 *                 type: string
 *               rol:
 *                 type: string
 *             required:
 *               - nombre
 *               - correo
 *               - password
 *               - rol
 *     responses:
 *       201:
 *         description: Usuario creado
 */
router.post('/', usuarioController.crearUsuario);
/**
 * @openapi
 * /api/v1/usuarios/{id}/rol:
 *   patch:
 *     summary: Actualizar el rol de un usuario
 *     tags:
 *       - Usuarios
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               rol:
 *                 type: string
 *             required:
 *               - rol
 *     responses:
 *       200:
 *         description: Rol actualizado
 */
router.patch('/:id/rol', authMiddleware, requireRoles(['Administrativo']), usuarioController.actualizarRolUsuario);

module.exports = router;
