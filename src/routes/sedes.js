const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { requireRoles } = require('../middleware/roleMiddleware');
const sedeController = require('../controllers/sedeController');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Sedes
 *   description: Endpoints para la gestión de sedes y bodegas
 */

/**
 * @openapi
 * /api/v1/sedes:
 *   get:
 *     summary: Obtener lista de sedes
 *     tags:
 *       - Sedes
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de sedes
 */
router.get('/', authMiddleware, sedeController.obtenerSedes);

/**
 * @openapi
 * /api/v1/sedes:
 *   post:
 *     summary: Crear una nueva sede
 *     tags:
 *       - Sedes
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
 *               direccion:
 *                 type: string
 *               codigo_establecimiento:
 *                 type: string
 *             required:
 *               - nombre
 *               - direccion
 *               - codigo_establecimiento
 *     responses:
 *       201:
 *         description: Sede creada
 */
router.post('/', authMiddleware, requireRoles(['Administrativo']), sedeController.crearSede);

module.exports = router;
