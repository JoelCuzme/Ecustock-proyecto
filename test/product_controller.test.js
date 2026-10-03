const test = require('node:test');
const assert = require('node:assert/strict');

const productoController = require('../src/controllers/productoController');
const productoModel = require('../src/models/productoModel');

function createRequest(body) {
  return {
    app: {
      locals: {
        db: {
          getConnection: async () => {
            throw new Error('La validación debió terminar antes de acceder a la base de datos.');
          },
        },
      },
    },
    body,
  };
}

async function invokeCreate(body) {
  let responseStatus = 200;
  let responseBody;
  let forwardedError;
  const response = {
    status(status) {
      responseStatus = status;
      return this;
    },
    json(value) {
      responseBody = value;
      return this;
    },
  };

  await productoController.crearProducto(
    createRequest(body),
    response,
    (error) => {
      forwardedError = error;
    },
  );

  return { responseStatus, responseBody, forwardedError };
}

test('rechaza códigos de barras no numéricos o fuera del rango de longitud', async () => {
  for (const codigo_barras of ['1234567', '123456789012345', '1234ABCD']) {
    const result = await invokeCreate({
      codigo_barras,
      nombre: 'Producto',
      precio_costo: 1,
      precio_venta: 2,
    });

    assert.equal(result.forwardedError.statusCode, 400);
  }
});

test('valida el rango del nombre, precios y stock mínimo', async () => {
  const invalidBodies = [
    { nombre: 'AB' },
    { nombre: 'Producto'.repeat(13) },
    { precio_costo: 0 },
    { precio_costo: 3, precio_venta: 3 },
    { stock_minimo: -1 },
  ];

  for (const invalid of invalidBodies) {
    const result = await invokeCreate({
      codigo_barras: '12345678',
      nombre: 'Producto',
      precio_costo: 1,
      precio_venta: 2,
      ...invalid,
    });

    assert.equal(result.forwardedError.statusCode, 400);
  }
});

test('responde 409 cuando el código de barras ya está registrado', async () => {
  const request = {
    app: {
      locals: {
        db: {
          getConnection: async () => ({
            query: async () => {
              const error = new Error('Duplicate barcode');
              error.code = 'ER_DUP_ENTRY';
              throw error;
            },
            release() {},
          }),
        },
      },
    },
    body: {
      codigo_barras: '12345678',
      nombre: 'Producto',
      precio_costo: 1,
      precio_venta: 2,
    },
  };
  let forwardedError;

  await productoController.crearProducto(request, {}, (error) => {
    forwardedError = error;
  });

  assert.equal(forwardedError.statusCode, 409);
});

test('crea el producto con ambos precios y devuelve 201', async () => {
  const savedProduct = { id: 7 };
  const request = {
    app: {
      locals: {
        db: {
          getConnection: async () => ({
            query: async (sql, params) => {
              if (sql.includes('INSERT INTO productos')) {
                Object.assign(savedProduct, {
                  codigo_barras: params[0],
                  nombre: params[1],
                  descripcion: params[2],
                  precio_costo: params[3],
                  precio_venta: params[4],
                  stock_actual: params[5],
                  stock_minimo: params[6],
                });
                return { insertId: savedProduct.id };
              }
              return [savedProduct];
            },
            release() {},
          }),
        },
      },
    },
    body: {
      codigo_barras: '12345678',
      nombre: 'Producto válido',
      precio_costo: 4.25,
      precio_venta: 6.5,
      stock_actual: 3,
      stock_minimo: 1,
    },
  };
  let responseStatus;
  let responseBody;
  let forwardedError;
  const response = {
    status(status) {
      responseStatus = status;
      return this;
    },
    json(value) {
      responseBody = value;
      return this;
    },
  };

  await productoController.crearProducto(request, response, (error) => {
    forwardedError = error;
  });

  assert.equal(forwardedError, undefined);
  assert.equal(responseStatus, 201);
  assert.equal(responseBody.product.precio_costo, 4.25);
  assert.equal(responseBody.product.precio_venta, 6.5);
});

test('bloquea la fila durante el egreso y confirma el nuevo stock', async () => {
  const statements = [];
  let committed = false;
  const pool = {
    getConnection: async () => ({
      async beginTransaction() {},
      async query(sql, params) {
        statements.push({ sql, params });
        if (sql.includes('FOR UPDATE')) {
          return [{
            id: 4,
            nombre: 'Producto',
            precio_costo: 1,
            stock_actual: 5,
            stock_minimo: 1,
          }];
        }
        return { affectedRows: 1 };
      },
      async commit() {
        committed = true;
      },
      async rollback() {
        assert.fail('La operación válida no debía revertirse.');
      },
      release() {},
    }),
  };

  const product = await productoModel.registerStockMovement(pool, 4, 'egreso', 2);

  assert.match(statements[0].sql, /FOR UPDATE/);
  assert.equal(statements[1].params[0], 3);
  assert.equal(product.stock_actual, 3);
  assert.equal(committed, true);
});

test('revierte y devuelve 409 cuando el egreso excede el stock', async () => {
  let committed = false;
  let rolledBack = false;
  const pool = {
    getConnection: async () => ({
      async beginTransaction() {},
      async query() {
        return [{
          id: 4,
          nombre: 'Producto',
          precio_costo: 1,
          stock_actual: 1,
          stock_minimo: 0,
        }];
      },
      async commit() {
        committed = true;
      },
      async rollback() {
        rolledBack = true;
      },
      release() {},
    }),
  };

  await assert.rejects(
    productoModel.registerStockMovement(pool, 4, 'egreso', 2),
    (error) => error.statusCode === 409,
  );
  assert.equal(committed, false);
  assert.equal(rolledBack, true);
});

test('revierte un movimiento si el producto antiguo no tiene precio de costo', async () => {
  let rolledBack = false;
  const pool = {
    getConnection: async () => ({
      async beginTransaction() {},
      async query() {
        return [{
          id: 4,
          nombre: 'Producto antiguo',
          precio_costo: null,
          stock_actual: 1,
          stock_minimo: 0,
        }];
      },
      async commit() {
        assert.fail('No debe confirmar un movimiento sin precio de costo.');
      },
      async rollback() {
        rolledBack = true;
      },
      release() {},
    }),
  };

  await assert.rejects(
    productoModel.registerStockMovement(pool, 4, 'egreso', 1),
    (error) => error.statusCode === 400,
  );
  assert.equal(rolledBack, true);
});
