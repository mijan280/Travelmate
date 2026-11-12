const { sendError } = require('../utils/response.util');

const validate = (validatorFn) => {
  return (req, res, next) => {
    const error = validatorFn(req.body);
    if (error) {
      return sendError(res, error, 400);
    }
    next();
  };
};

module.exports = validate;
