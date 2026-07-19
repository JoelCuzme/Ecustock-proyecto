function errorHandler(err, req, res, next) {
  const statusCode = err.statusCode || err.status || 500;
  const status = Number.isInteger(statusCode) ? statusCode : 500;

  const baseMessage =
    status >= 500
      ? 'Lo sentimos, algo salió mal en nuestros servidores. Inténtalo más tarde.'
      : 'Ocurrió un error al procesar la solicitud. Revisa los datos e intenta de nuevo.';

  const payload = {
    error: err.name || 'Error',
    message: status >= 500 ? baseMessage : err.message || baseMessage,
  };

  if (err.details) {
    payload.details = err.details;
  }

  if (process.env.NODE_ENV !== 'production') {
    payload.stack = err.stack;
  }

  if (res.headersSent) {
    return next(err);
  }

  res.status(status).json(payload);
}

module.exports = errorHandler;
