const path = require('path');
const express = require('express');
const dotenv = require('dotenv');
const mariadb = require('mariadb');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');
const authRoutes = require('./routes/auth');
const usuariosRoutes = require('./routes/usuarios');
const productosRoutes = require('./routes/productos');
const sedesRoutes = require('./routes/sedes');
const rolesRoutes = require('./routes/roles');
const errorHandler = require('./middleware/errorHandler');

dotenv.config({ path: path.resolve(__dirname, '../.env') });

const PORT = process.env.PORT || 3000;

const app = express();
app.use(express.json());

const pool = mariadb.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ecustock',
  port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
  connectionLimit: 5,
});

app.locals.db = pool;

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/usuarios', usuariosRoutes);
app.use('/api/v1/sedes', sedesRoutes);
app.use('/api/v1/roles', rolesRoutes);
app.use('/api/v1/productos', productosRoutes);
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { explorer: true }));

app.use((req, res, next) => {
  const notFoundError = new Error('Endpoint no encontrado');
  notFoundError.statusCode = 404;
  next(notFoundError);
});

app.use(errorHandler);

async function startServer() {
  try {
    const conn = await pool.getConnection();
    conn.release();
    console.log('Conectado a MariaDB satisfactoriamente');
  } catch (error) {
    console.error('No se pudo conectar a MariaDB:', error.message);
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
    console.log(`Documentación disponible en http://localhost:${PORT}/api/docs`);
  });
}

startServer();
