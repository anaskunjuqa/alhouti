#!/bin/bash

# Bash script to set up and run Docker tests
ACTION=${1:-help}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function write_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

function write_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function write_error() {
    echo -e "${RED}❌ $1${NC}"
}

function test_docker_installed() {
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        write_success "Docker is installed: $docker_version"
        return 0
    else
        write_error "Docker is not installed or not running"
        write_info "Please install Docker from: https://www.docker.com/get-started/"
        return 1
    fi
}

function build_docker_image() {
    write_info "Building Docker image..."
    if docker build -t alhouti-playwright .; then
        write_success "Docker image built successfully"
    else
        write_error "Failed to build Docker image"
        exit 1
    fi
}

function run_docker_tests() {
    write_info "Running tests in Docker container..."
    
    # Create directories if they don't exist
    mkdir -p allure-results allure-report playwright-report test-results
    
    if docker run --rm \
        -v "$(pwd)/allure-results:/app/allure-results" \
        -v "$(pwd)/allure-report:/app/allure-report" \
        -v "$(pwd)/playwright-report:/app/playwright-report" \
        -v "$(pwd)/test-results:/app/test-results" \
        -e CI=true \
        alhouti-playwright npm run test; then
        write_success "Tests completed successfully"
    else
        write_error "Tests failed"
    fi
}

function generate_allure_report() {
    write_info "Generating Allure report..."
    if docker run --rm \
        -v "$(pwd)/allure-results:/app/allure-results" \
        -v "$(pwd)/allure-report:/app/allure-report" \
        alhouti-playwright npx allure generate allure-results --clean -o allure-report; then
        write_success "Allure report generated successfully"
    fi
}

function start_allure_server() {
    write_info "Starting Allure server on http://localhost:4040"
    docker run --rm -p 4040:4040 \
        -v "$(pwd)/allure-results:/app/allure-results" \
        alhouti-playwright npx allure serve allure-results --port 4040 --host 0.0.0.0
}

function show_help() {
    echo -e "${YELLOW}🐳 Docker Test Runner for Alhouti Playwright Tests

Usage: ./scripts/docker-setup.sh <action>

Actions:
  help          Show this help message
  check         Check if Docker is installed and running
  build         Build the Docker image
  test          Run tests in Docker container
  allure        Generate Allure report
  serve         Start Allure server (http://localhost:4040)
  full          Build image, run tests, and generate report
  clean         Clean up Docker containers and images

Examples:
  ./scripts/docker-setup.sh build
  ./scripts/docker-setup.sh test
  ./scripts/docker-setup.sh full${NC}"
}

function cleanup_docker() {
    write_info "Cleaning up Docker containers and images..."
    docker container prune -f
    docker rmi alhouti-playwright -f 2>/dev/null || true
    write_success "Cleanup completed"
}

# Main execution
case $ACTION in
    help)
        show_help
        ;;
    check)
        test_docker_installed
        ;;
    build)
        if test_docker_installed; then
            build_docker_image
        fi
        ;;
    test)
        if test_docker_installed; then
            run_docker_tests
        fi
        ;;
    allure)
        if test_docker_installed; then
            generate_allure_report
        fi
        ;;
    serve)
        if test_docker_installed; then
            start_allure_server
        fi
        ;;
    full)
        if test_docker_installed; then
            build_docker_image
            run_docker_tests
            generate_allure_report
            write_success "Full test cycle completed!"
        fi
        ;;
    clean)
        cleanup_docker
        ;;
    *)
        write_error "Unknown action: $ACTION"
        show_help
        ;;
esac
