const express = require('express');
const dotenv = require('dotenv');
const os = require('os');
const axios = require('axios');
const { getUserCount, createUser } = require('./services/userService');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const APP_ENV = process.env.APP_ENV || 'local';

async function getEcsTaskId() {
  try {
    const metadataUri = process.env.ECS_CONTAINER_METADATA_URI_V4;
    if (!metadataUri) return null;
    const res = await axios.get(`${metadataUri}/task`);
    const taskArn = res.data.TaskARN;
    return taskArn.split("/").pop(); 
  } catch (err) {
    console.log('Failed to get ECS Task ID:', err.message);
    return null;
  }
}

let ECS_TASK_ID = null;
let TASK_ID = null

const INSTANCE_START_TIME = new Date().toISOString();

app.use(express.json());

app.get('/', async (req, res) => {
  const userCount = await getUserCount();
  res.json({
    message: `Hello from ${APP_ENV} environment!`,
    timestamp: new Date().toISOString(),
    environment: APP_ENV,
    taskId: ECS_TASK_ID || TASK_ID,
    ecsTaskId: ECS_TASK_ID,
    fallbackTaskId: TASK_ID,
    hostname: os.hostname(),
    processId: process.pid,
    instanceStartTime: INSTANCE_START_TIME,
    uptime: process.uptime(),
    isEcsEnvironment: !!ECS_TASK_ID,
    userCount,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    version: '1.0.4',
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Service is healthy',
  });
});

app.post('/users', async (req, res) => {
  try {
    const { username, email, fullName } = req.body;

    if (!username || !email) {
      return res.status(400).json({
        status: 'ERROR',
        message: 'Username and email are required'
      });
    }

    const newUser = await createUser(username, email, fullName);
    res.status(201).json({
      status: 'OK',
      message: 'User created successfully',
      user: newUser
    });
  } catch (error) {
    console.error('Error creating user:', error);

    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(409).json({
        status: 'ERROR',
        message: 'Username or email already exists'
      });
    }

    res.status(500).json({
      status: 'ERROR',
      message: 'Failed to create user',
      error: error.message
    });
  }
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

const server = app.listen(PORT, async () => {
  console.log(`Server is running on port ${PORT} in ${APP_ENV} environment`);
  try {
    ECS_TASK_ID = await getEcsTaskId();
    if (ECS_TASK_ID) {
      console.log(`ECS Task ID: ${ECS_TASK_ID}`);
    } else {
      console.log(`Not running in ECS, using fallback Task ID: ${TASK_ID}`);
    }
  } catch (error) {
    console.log(`Failed to get ECS Task ID, using fallback: ${TASK_ID}`);
  }

  console.log(`Hostname: ${os.hostname()}`);
  console.log(`Process ID: ${process.pid}`);
});

module.exports = { app, server };