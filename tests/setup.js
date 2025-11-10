const dotenv = require('dotenv');
dotenv.config({ path: './test.env' });

if (process.env.JEST_TIMEOUT) {
  jest.setTimeout(parseInt(process.env.JEST_TIMEOUT));
}

global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};

afterAll(async () => {
    // Add any global cleanup here
});