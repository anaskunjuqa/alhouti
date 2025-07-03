# Docker Setup for Playwright Tests

This project supports running Playwright tests in Docker containers for consistent testing environments.

## Prerequisites

- Docker installed on your system
- Docker Compose installed

## Quick Start

### 1. Build the Docker image
```bash
npm run docker:build
```

### 2. Run tests in Docker
```bash
# Run basic tests
npm run docker:test

# Run tests with Allure report generation
npm run docker:test-allure
```

### 3. Serve Allure reports
```bash
# Start Allure server (accessible at http://localhost:4040)
npm run docker:allure-serve
```

## Available Docker Commands

| Command | Description |
|---------|-------------|
| `npm run docker:build` | Build the Docker image |
| `npm run docker:test` | Run tests in Docker container |
| `npm run docker:test-allure` | Run tests and generate Allure report |
| `npm run docker:allure-serve` | Serve Allure reports on port 4040 |
| `npm run docker:clean` | Clean up Docker containers and images |

## Manual Docker Commands

### Build and run tests
```bash
# Build the image
docker build -t alhouti-playwright .

# Run tests
docker run --rm -v $(pwd)/allure-results:/app/allure-results alhouti-playwright

# Run with interactive mode
docker run --rm -it -v $(pwd):/app alhouti-playwright bash
```

### Using Docker Compose
```bash
# Run tests
docker-compose run --rm playwright-tests

# Run tests with Allure
docker-compose run --rm playwright-allure

# Start Allure server
docker-compose up allure-server

# Clean up
docker-compose down
```

## Benefits of Docker Testing

- **Consistent Environment**: Same testing environment across all machines
- **Isolation**: Tests run in isolated containers
- **CI/CD Ready**: Easy integration with CI/CD pipelines
- **Browser Dependencies**: All browser dependencies pre-installed
- **Reproducible Results**: Consistent test execution

## Troubleshooting

### Permission Issues
If you encounter permission issues with volumes:
```bash
# Fix permissions (Linux/Mac)
sudo chown -R $USER:$USER allure-results allure-report playwright-report
```

### Container Cleanup
```bash
# Remove all containers
docker container prune

# Remove all images
docker image prune

# Complete cleanup
npm run docker:clean
```
