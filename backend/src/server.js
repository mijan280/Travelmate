const createApp = require('./app');
const config = require('./config');

const app = createApp();

const server = app.listen(config.port, config.host, () => {
  console.log('====================================================');
  console.log(`🚀 TravelMate REST API Server Started Successfully`);
  console.log(`📡 Listening on: http://${config.host}:${config.port}`);
  console.log(`📱 Android Emulator URL: http://10.0.2.2:${config.port}/api`);
  console.log(`📱 Physical Phone URL:   http://<YOUR_LAPTOP_IP>:${config.port}/api`);
  console.log(`🩺 Health Check:         http://localhost:${config.port}/api/health`);
  console.log(`📁 Persistent Data Dir:  ${config.dataDir}`);
  console.log(`⚙️  Environment:          ${config.nodeEnv}`);
  console.log('====================================================');
});

// Handle graceful shutdown
const shutdown = () => {
  console.log('\nGracefully shutting down TravelMate server...');
  server.close(() => {
    console.log('HTTP server closed.');
    process.exit(0);
  });
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);

module.exports = server;
