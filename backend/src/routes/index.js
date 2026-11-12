const express = require('express');
const config = require('../config');

// Storage
const JsonStorageAdapter = require('../storage/json/JsonStorageAdapter');

// Repositories
const UserRepository = require('../repositories/userRepository');
const DestinationRepository = require('../repositories/destinationRepository');

// Services
const AuthService = require('../services/authService');
const UserService = require('../services/userService');
const DestinationService = require('../services/destinationService');

// Controllers
const AuthController = require('../controllers/auth.controller');
const UserController = require('../controllers/user.controller');
const DestinationController = require('../controllers/destination.controller');

// Routes
const healthRoutes = require('./health.routes');
const createAuthRoutes = require('./auth.routes');
const createUserRoutes = require('./user.routes');
const createDestinationRoutes = require('./destination.routes');

const createApiRouter = () => {
  const router = express.Router();

  // Initialize storage adapter with configured data directory
  const storageAdapter = new JsonStorageAdapter(config.dataDir);

  // Initialize repositories
  const userRepository = new UserRepository(storageAdapter);
  const destinationRepository = new DestinationRepository(storageAdapter);

  // Initialize services
  const authService = new AuthService(userRepository);
  const userService = new UserService(userRepository);
  const destinationService = new DestinationService(destinationRepository);

  // Initialize controllers
  const authController = new AuthController(authService);
  const userController = new UserController(userService);
  const destinationController = new DestinationController(destinationService);

  // Mount feature routes
  router.use('/health', healthRoutes);
  router.use('/auth', createAuthRoutes(authController));
  router.use('/users', createUserRoutes(userController));
  router.use('/destinations', createDestinationRoutes(destinationController));

  return {
    router,
    storageAdapter,
    userRepository,
    destinationRepository,
  };
};

module.exports = createApiRouter;
