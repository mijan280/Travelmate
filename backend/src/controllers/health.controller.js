const { sendSuccess } = require('../utils/response.util');

const getHealth = (req, res) => {
  return sendSuccess(res, 'TravelMate REST API is running and healthy', {
    status: 'UP',
    service: 'travelmate-backend',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.floor(process.uptime()),
    clientIp: req.ip,
  });
};

module.exports = {
  getHealth,
};
