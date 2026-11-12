/**
 * Standardized API Response Utilities
 *
 * Success response shape:
 * {
 *   "success": true,
 *   "message": "...",
 *   "data": { ... }
 * }
 *
 * Error response shape:
 * {
 *   "success": false,
 *   "message": "...",
 *   "data": null
 * }
 */

const sendSuccess = (res, message = 'Success', data = {}, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

const sendError = (res, message = 'Error', statusCode = 400, data = null) => {
  return res.status(statusCode).json({
    success: false,
    message,
    data,
  });
};

module.exports = {
  sendSuccess,
  sendError,
};
