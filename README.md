# ATM Blue Node API

A simple Node.js API application with health check and environment-aware endpoints.

## Features

- ✅ Health check endpoint (`/health`)
- ✅ Home endpoint (`/`) with environment information
- ✅ Docker Compose configuration
- ✅ Comprehensive test suite
- ✅ Environment configuration support

## Requirements

- Node.js >= 20.0.0
- Docker (optional)
- Docker Compose (optional)

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   yarn install
   ```

3. Create environment file:
   ```bash
   cp .env .env.local
   ```

4. Modify `.env.local` with your configuration

## Usage

### Local Development

```bash
# Start in development mode
yarn dev

# Start in production mode
yarn start
```

### API Endpoints

#### GET /
Returns a hello message with the current environment.

**Response:**
```json
{
  "message": "Hello from local environment!",
  "timestamp": "2025-11-01T10:00:00.000Z",
  "environment": "local"
}
```

#### GET /health
Returns application health status.

**Response:**
```json
{
  "status": "OK",
  "message": "Service is healthy",
  "timestamp": "2025-11-01T10:00:00.000Z",
  "environment": "local",
  "uptime": 123.456,
  "version": "1.0.0"
}
```

### Environment Variables

- `APP_ENV`: Application environment (`local`, `dev`, `prod`)
- `PORT`: Server port (default: 3000)

## Testing

```bash
# Run tests
yarn test

# Run tests in watch mode
yarn test:watch

# Run tests with coverage
yarn test:coverage
```

## Docker

### Build and Run

```bash
# Build production image
docker build -t atm-blue-node .

# Run production container
docker run -p 3000:3000 -e APP_ENV=prod atm-blue-node
```

### Docker Compose

```bash
# Development environment
docker-compose up
```

## API Testing

You can test the API endpoints using curl:

```bash
# Test home endpoint
curl http://localhost:3000/

# Test health check
curl http://localhost:3000/health

# Test 404 handling
curl http://localhost:3000/non-existent
```

## License

MIT
