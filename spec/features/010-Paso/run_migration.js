const path = require('path');
const fs = require('fs');
const dotenv = require('dotenv');
const mariadb = require('mariadb');

dotenv.config({ path: path.resolve(__dirname, '../../../.env') });

const SQL_DIRECTORY = __dirname;
const sqlFiles = fs
  .readdirSync(SQL_DIRECTORY)
  .filter((file) => file.toLowerCase().endsWith('.sql'))
  .sort();

if (sqlFiles.length === 0) {
  console.error('No se encontraron archivos SQL en:', SQL_DIRECTORY);
  process.exit(2);
}

async function run() {
  const pool = mariadb.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ecustock',
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
    connectionLimit: 5,
  });

  let conn;
  try {
    conn = await pool.getConnection();
    console.log('Conectado a la base de datos. Ejecutando migraciones...');
    for (const file of sqlFiles) {
      const filePath = path.resolve(SQL_DIRECTORY, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      console.log(`Ejecutando ${file}...`);
      await conn.query(sql);
    }
    console.log('Migraciones ejecutadas correctamente.');
  } catch (err) {
    console.error('Error al ejecutar la migración:', err);
    process.exit(1);
  } finally {
    if (conn) conn.release();
    try { await pool.end(); } catch (e) {}
  }
}

run();
