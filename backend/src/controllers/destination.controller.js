const { sendSuccess, sendError } = require('../utils/response.util');

class DestinationController {
  constructor(destinationService) {
    this.destinationService = destinationService;
  }

  getAll = async (req, res, next) => {
    try {
      const { popular, search } = req.query;
      const filter = {};
      if (popular !== undefined) {
        filter.popular = popular === 'true' || popular === '1';
      }
      if (search) {
        filter.search = String(search);
      }

      const list = await this.destinationService.getAll(filter);
      return sendSuccess(res, 'Destinations retrieved successfully', list);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  getPopular = async (req, res, next) => {
    try {
      const list = await this.destinationService.getPopular();
      return sendSuccess(res, 'Popular destinations retrieved successfully', list);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  getById = async (req, res, next) => {
    try {
      const item = await this.destinationService.getById(req.params.id);
      return sendSuccess(res, 'Destination retrieved successfully', item);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  create = async (req, res, next) => {
    try {
      const created = await this.destinationService.create(req.body);
      return sendSuccess(res, 'Destination created successfully', created, 201);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  update = async (req, res, next) => {
    try {
      const updated = await this.destinationService.update(req.params.id, req.body);
      return sendSuccess(res, 'Destination updated successfully', updated);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };

  delete = async (req, res, next) => {
    try {
      await this.destinationService.delete(req.params.id);
      return sendSuccess(res, 'Destination deleted successfully', null);
    } catch (err) {
      if (err.statusCode) {
        return sendError(res, err.message, err.statusCode);
      }
      next(err);
    }
  };
}

module.exports = DestinationController;
