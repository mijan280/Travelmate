const { verifyToken } = require('../utils/token.util');
const { sendError } = require('../utils/response.util');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return sendError(res, 'Authorization token is required', 401);
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return sendError(res, 'Invalid authorization header format. Format must be: Bearer <token>', 401);
  }

  const token = parts[1];
  try {
    const decoded = verifyToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return sendError(res, 'Token has expired. Please log in again.', 401);
    }
    return sendError(res, 'Invalid token. Access denied.', 401);
  }
};

module.exports = {
  authenticateToken,
};
