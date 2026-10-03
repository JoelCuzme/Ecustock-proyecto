-- Migration: Crear tabla productos
-- Ejecutar en la base de datos `ecustock` en MariaDB

CREATE TABLE IF NOT EXISTS productos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo_barras VARCHAR(50) NOT NULL UNIQUE,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio_costo DECIMAL(10,2) NOT NULL,
  precio_venta DECIMAL(10,2) NOT NULL,
  stock_actual INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 5,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_productos_codigo_barras CHECK (codigo_barras REGEXP '^[0-9]{8,14}$'),
  CONSTRAINT chk_productos_nombre CHECK (CHAR_LENGTH(nombre) BETWEEN 3 AND 100),
  CONSTRAINT chk_productos_precio_costo CHECK (precio_costo > 0),
  CONSTRAINT chk_productos_precio_venta CHECK (precio_venta > 0),
  CONSTRAINT chk_productos_precios CHECK (precio_venta > precio_costo),
  CONSTRAINT chk_productos_stock_actual CHECK (stock_actual >= 0),
  CONSTRAINT chk_productos_stock_minimo CHECK (stock_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
