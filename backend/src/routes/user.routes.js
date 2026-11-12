const express = require('express');
const validate = require('../middleware/validate.middleware');
const { validateProfileUpdate } = require('../validators/authValidator');
const { authenticateToken } = require('../middleware/auth.middleware');

const createUserRouter = (userController) => {
  const router = express.Router();

  router.use(authenticateToken);
  router.get('/me', userController.getMe);
  router.put('/me', validate(validateProfileUpdate), userController.updateMe);

  return router;
};

module.exports = createUserRouter;
