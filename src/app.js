const express = require('express');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const APP_ENV = process.env.APP_ENV || 'local';

app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    message: `Hello from ${APP_ENV} environment!`,
    timestamp: new Date().toISOString(),
    environment: APP_ENV
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Service is healthy',
    timestamp: new Date().toISOString(),
    environment: APP_ENV,
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    status: 'ERROR',
    message: 'Something went wrong!'
  });
});

app.use('*', (req, res) => {
  res.status(404).json({
    status: 'ERROR',
    message: 'Route not found'
  });
});

const server = app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT} in ${APP_ENV} environment`);
});

module.exports = { app, server };