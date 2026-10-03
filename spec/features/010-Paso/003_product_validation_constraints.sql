-- Completa restricciones para tablas productos ya creadas.
-- Los costos de productos existentes quedan NULL para cargarlos desde una fuente confiable.
-- Los códigos de barras nulos preexistentes se conservan; la API exige código en altas y cambios.

ALTER TABLE productos
  ADD COLUMN IF NOT EXISTS precio_costo DECIMAL(10,2) NULL AFTER descripcion;

UPDATE productos
SET stock_minimo = 5
WHERE stock_minimo IS NULL;

ALTER TABLE productos
  MODIFY stock_minimo INT NOT NULL DEFAULT 5;

ALTER TABLE productos
  ADD CONSTRAINT IF NOT EXISTS chk_productos_codigo_barras
    CHECK (codigo_barras IS NULL OR codigo_barras REGEXP '^[0-9]{8,14}$'),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_nombre
    CHECK (CHAR_LENGTH(nombre) BETWEEN 3 AND 100),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_precio_costo
    CHECK (precio_costo IS NULL OR precio_costo > 0),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_precio_venta
    CHECK (precio_venta > 0),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_precios
    CHECK (precio_costo IS NULL OR precio_venta > precio_costo),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_stock_actual
    CHECK (stock_actual >= 0),
  ADD CONSTRAINT IF NOT EXISTS chk_productos_stock_minimo
    CHECK (stock_minimo >= 0);
