const { sendSuccess, sendError } = require('../utils/response.util');

class UserController {
  constructor(userService) {
    this.userService = userService;
  }

  getMe = async (req, res, next) => {
    try {
      const user = await this.userService.getUserById(req.user.id);
      return sendSuccess(res, 'User profile retrieved successfully', user);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  updateMe = async (req, res, next) => {
    try {
      const updated = await this.userService.updateProfile(req.user.id, req.body);
      return sendSuccess(res, 'Profile updated successfully', updated);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };
}

module.exports = UserController;
