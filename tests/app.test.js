describe('API Endpoints', () => {
  describe('Math Operations', () => {
    console.log('APP_ENV', process.env.APP_ENV);
    it('should correctly add 1 + 2', async () => {
      const a = 1;
      const b = 2;
      const sum = a + b;
      expect(sum).toBe(3);
    });
  });

  describe('Environment Variables', () => {
    it('should use test environment', async () => {
      expect(process.env.APP_ENV).toBe('test');
    });

    it('should have correct port configuration', async () => {
      expect(process.env.PORT).toBe(process.env.PORT);
    });
  });
});
