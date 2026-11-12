const { sendError } = require('../utils/response.util');
const config = require('../config');

const notFoundHandler = (req, res) => {
  return sendError(res, `Route not found: ${req.method} ${req.originalUrl}`, 404);
};

const errorHandler = (err, req, res, next) => {
  console.error('[ErrorHandler] Unhandled exception:', err);

  const statusCode = err.statusCode || 500;
  const message = config.nodeEnv === 'production' && statusCode === 500
    ? 'Internal server error occurred'
    : err.message || 'Internal server error occurred';

  return sendError(res, message, statusCode);
};

module.exports = {
  notFoundHandler,
  errorHandler,
};
