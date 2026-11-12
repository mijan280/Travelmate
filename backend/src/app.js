const express = require('express');
const cors = require('cors');
const requestLogger = require('./middleware/requestLogger.middleware');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler.middleware');
const createApiRouter = require('./routes');

const createApp = () => {
  const app = express();

  // Cross-Origin Resource Sharing
  app.use(cors());

  // Request Body Parsers
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Logging
  app.use(requestLogger);

  // Root Welcome Endpoint
  app.get('/', (req, res) => {
    res.json({
      success: true,
      message: 'TravelMate REST API Server (Lab Task 3)',
      version: '1.0.0',
      endpoints: {
        health: '/api/health',
        auth: {
          register: 'POST /api/auth/register',
          login: 'POST /api/auth/login',
          me: 'GET /api/auth/me',
        },
        users: {
          me: 'GET /api/users/me',
          updateMe: 'PUT /api/users/me',
        },
        destinations: {
          list: 'GET /api/destinations',
          popular: 'GET /api/destinations/popular',
          detail: 'GET /api/destinations/:id',
          create: 'POST /api/destinations',
          update: 'PUT /api/destinations/:id',
          delete: 'DELETE /api/destinations/:id',
        },
      },
    });
  });

  // Mount API Routes
  const { router } = createApiRouter();
  app.use('/api', router);

  // 404 Catch-All
  app.use(notFoundHandler);

  // Centralized Error Handler
  app.use(errorHandler);

  return app;
};

module.exports = createApp;
