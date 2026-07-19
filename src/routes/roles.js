const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { requireRoles } = require('../middleware/roleMiddleware');
const rolController = require('../controllers/rolController');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Roles
 *   description: Endpoints para la gestión de roles y permisos
 */

/**
 * @openapi
 * /api/v1/roles:
 *   get:
 *     summary: Obtener lista de roles con permisos
 *     tags:
 *       - Roles
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Roles con permisos
 */
router.get('/', authMiddleware, requireRoles(['Administrativo']), rolController.obtenerRoles);

/**
 * @openapi
 * /api/v1/roles/{id}/permisos:
 *   put:
 *     summary: Actualizar permisos de un rol
 *     tags:
 *       - Roles
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
 *               permisos:
 *                 type: array
 *                 items:
 *                   type: integer
 *     responses:
 *       200:
 *         description: Permisos actualizados
 */
router.put('/:id/permisos', authMiddleware, requireRoles(['Administrativo']), rolController.actualizarPermisosRol);

module.exports = router;
