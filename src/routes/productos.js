const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { requireRoles } = require('../middleware/roleMiddleware');
const cacheService = require('../services/cacheService');
const productoController = require('../controllers/productoController');
const router = express.Router();

/**
 * @openapi
 * components:
 *   securitySchemes:
 *     BearerAuth:
 *       type: http
 *       scheme: bearer
 *       bearerFormat: JWT
 *   schemas:
 *     Producto:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         codigo_barras:
 *           type: string
 *         nombre:
 *           type: string
 *         descripcion:
 *           type: string
 *         precio_venta:
 *           type: number
 *           format: float
 *         precio_costo:
 *           type: number
 *           format: float
 *         stock_actual:
 *           type: integer
 *         stock_minimo:
 *           type: integer
 *         created_at:
 *           type: string
 *           format: date-time
 *         updated_at:
 *           type: string
 *           format: date-time
 */

/**
 * @openapi
 * /api/v1/productos:
 *   get:
 *     tags:
 *       - Productos
 *     summary: Obtener lista de productos
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de productos
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 products:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Producto'
 */
router.get('/', authMiddleware, async (req, res, next) => {
  try {
    // Cache simple: return cached list when available
    const cached = cacheService.get('productList');
    if (cached) {
      return res.json({ success: true, source: 'cache', products: cached });
    }

    await productoController.obtenerProductos(req, res, next);
  } catch (error) {
    next(error);
  }
});

router.get(
  '/codigo/:codigoBarras',
  authMiddleware,
  productoController.obtenerProductoPorCodigo,
);

/**
 * @openapi
 * /api/v1/productos/{id}/movimientos:
 *   post:
 *     tags:
 *       - Productos
 *     summary: Registrar un movimiento de inventario
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
 *             required: [tipo, cantidad]
 *             properties:
 *               tipo:
 *                 type: string
 *                 enum: [ingreso, egreso]
 *               cantidad:
 *                 type: integer
 *                 minimum: 1
 *     responses:
 *       200:
 *         description: Movimiento registrado y stock actualizado
 *       400:
 *         description: Parámetros inválidos
 *       403:
 *         description: Rol sin permiso para registrar movimientos
 *       409:
 *         description: Stock insuficiente para el egreso
 */
router.post(
  '/:id/movimientos',
  authMiddleware,
  requireRoles(['Administrativo', 'Bodega']),
  async (req, res, next) => {
  try {
    cacheService.invalidate('productList');
    await productoController.registrarMovimientoStock(req, res, next);
  } catch (error) {
    next(error);
  }
  },
);

/**
 * @openapi
 * /api/v1/productos/{id}:
 *   get:
 *     tags:
 *       - Productos
 *     summary: Obtener un producto por id
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Producto encontrado
 */
router.get('/:id', authMiddleware, productoController.obtenerProductoPorId);

/**
 * @openapi
 * /api/v1/productos:
 *   post:
 *     tags:
 *       - Productos
 *     summary: Crear un nuevo producto
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Producto'
 *     responses:
 *       201:
 *         description: Producto creado
 */
router.post('/', authMiddleware, async (req, res, next) => {
  try {
    // Invalidate cache on create
    cacheService.invalidate('productList');
    await productoController.crearProducto(req, res, next);
  } catch (error) {
    next(error);
  }
});

/**
 * @openapi
 * /api/v1/productos/{id}:
 *   put:
 *     tags:
 *       - Productos
 *     summary: Actualizar un producto
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
 *             $ref: '#/components/schemas/Producto'
 *     responses:
 *       200:
 *         description: Producto actualizado
 */
router.put('/:id', authMiddleware, async (req, res, next) => {
  try {
    cacheService.invalidate('productList');
    await productoController.actualizarProducto(req, res, next);
  } catch (error) {
    next(error);
  }
});

/**
 * @openapi
 * /api/v1/productos/{id}:
 *   delete:
 *     tags:
 *       - Productos
 *     summary: Eliminar un producto
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Producto eliminado
 */
router.delete('/:id', authMiddleware, async (req, res, next) => {
  try {
    cacheService.invalidate('productList');
    await productoController.eliminarProducto(req, res, next);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
