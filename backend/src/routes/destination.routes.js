const express = require('express');
const validate = require('../middleware/validate.middleware');
const {
  validateCreateDestination,
  validateUpdateDestination,
} = require('../validators/destinationValidator');

const createDestinationRouter = (destinationController) => {
  const router = express.Router();

  router.get('/', destinationController.getAll);
  router.get('/popular', destinationController.getPopular);
  router.get('/:id', destinationController.getById);
  router.post('/', validate(validateCreateDestination), destinationController.create);
  router.put('/:id', validate(validateUpdateDestination), destinationController.update);
  router.delete('/:id', destinationController.delete);

  return router;
};

module.exports = createDestinationRouter;
