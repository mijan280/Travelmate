const { sendSuccess, sendError } = require('../utils/response.util');

class AuthController {
  constructor(authService) {
    this.authService = authService;
  }

  register = async (req, res, next) => {
    try {
      const result = await this.authService.register(req.body);
      return sendSuccess(res, 'Account created successfully', result, 201);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  login = async (req, res, next) => {
    try {
      const result = await this.authService.login(req.body);
      return sendSuccess(res, 'Login successful', result, 200);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  getCurrentUser = async (req, res, next) => {
    try {
      const user = await this.authService.getCurrentUser(req.user.id);
      return sendSuccess(res, 'Current user profile retrieved', user, 200);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };
}

module.exports = AuthController;
