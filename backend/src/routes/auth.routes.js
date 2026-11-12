const express = require('express');
const validate = require('../middleware/validate.middleware');
const { validateRegister, validateLogin } = require('../validators/authValidator');
const { authenticateToken } = require('../middleware/auth.middleware');

const createAuthRouter = (authController) => {
  const router = express.Router();

  router.post('/register', validate(validateRegister), authController.register);
  router.post('/login', validate(validateLogin), authController.login);
  router.get('/me', authenticateToken, authController.getCurrentUser);

  return router;
};

module.exports = createAuthRouter;
