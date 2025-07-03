# Use the official Playwright image with Node.js
FROM mcr.microsoft.com/playwright:v1.53.1-jammy

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Create directories for reports
RUN mkdir -p allure-results allure-report playwright-report

# Set environment variables
ENV CI=true
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Default command to run tests
CMD ["npm", "run", "test"]
