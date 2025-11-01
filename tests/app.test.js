const request = require('supertest');
const { app, server } = require('../src/app');

describe('API Endpoints', () => {
  afterAll((done) => {
    server.close(done);
  });

  describe('GET /', () => {
    it('should return hello message with environment', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('environment');
      expect(response.body.message).toContain('Hello from');
      expect(response.body.environment).toBeDefined();
    });

    it('should return environment from APP_ENV', async () => {
      const response = await request(app)
        .get('/')
        .expect(200);

      expect(['local', 'dev', 'prod']).toContain(response.body.environment);
    });
  });

  describe('GET /health', () => {
    it('should return health check status', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(response.body).toHaveProperty('status', 'OK');
      expect(response.body).toHaveProperty('message', 'Service is healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('environment');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('version');
    });

    it('should return uptime as a number', async () => {
      const response = await request(app)
        .get('/health')
        .expect(200);

      expect(typeof response.body.uptime).toBe('number');
      expect(response.body.uptime).toBeGreaterThanOrEqual(0);
    });
  });

  describe('404 Handler', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(app)
        .get('/non-existent-route')
        .expect(404);

      expect(response.body).toHaveProperty('status', 'ERROR');
      expect(response.body).toHaveProperty('message', 'Route not found');
    });
  });
});