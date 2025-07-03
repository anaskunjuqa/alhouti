# PowerShell script to set up and run Docker tests
param(
    [string]$Action = "help",
    [switch]$Verbose
)

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-DockerInstalled {
    try {
        $dockerVersion = docker --version 2>$null
        if ($dockerVersion) {
            Write-Success "Docker is installed: $dockerVersion"
            return $true
        }
    }
    catch {
        Write-Error "Docker is not installed or not running"
        Write-Info "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/"
        return $false
    }
}

function Build-DockerImage {
    Write-Info "Building Docker image..."
    docker build -t alhouti-playwright .
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker image built successfully"
    } else {
        Write-Error "Failed to build Docker image"
        exit 1
    }
}

function Run-DockerTests {
    Write-Info "Running tests in Docker container..."
    
    # Create directories if they don't exist
    $dirs = @("allure-results", "allure-report", "playwright-report", "test-results")
    foreach ($dir in $dirs) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    docker run --rm `
        -v "${PWD}/allure-results:/app/allure-results" `
        -v "${PWD}/allure-report:/app/allure-report" `
        -v "${PWD}/playwright-report:/app/playwright-report" `
        -v "${PWD}/test-results:/app/test-results" `
        -e CI=true `
        alhouti-playwright npm run test
        
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tests completed successfully"
    } else {
        Write-Error "Tests failed"
    }
}

function Generate-AllureReport {
    Write-Info "Generating Allure report..."
    docker run --rm `
        -v "${PWD}/allure-results:/app/allure-results" `
        -v "${PWD}/allure-report:/app/allure-report" `
        alhouti-playwright npx allure generate allure-results --clean -o allure-report
        
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Allure report generated successfully"
    }
}

function Start-AllureServer {
    Write-Info "Starting Allure server on http://localhost:4040"
    docker run --rm -p 4040:4040 `
        -v "${PWD}/allure-results:/app/allure-results" `
        alhouti-playwright npx allure serve allure-results --port 4040 --host 0.0.0.0
}

function Show-Help {
    Write-Host @"
🐳 Docker Test Runner for Alhouti Playwright Tests

Usage: .\scripts\docker-setup.ps1 -Action <action>

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
  .\scripts\docker-setup.ps1 -Action build
  .\scripts\docker-setup.ps1 -Action test
  .\scripts\docker-setup.ps1 -Action full
"@ -ForegroundColor Yellow
}

# Main execution
switch ($Action.ToLower()) {
    "help" { Show-Help }
    "check" { Test-DockerInstalled }
    "build" {
        if (Test-DockerInstalled) {
            Build-DockerImage
        }
    }
    "test" {
        if (Test-DockerInstalled) {
            Run-DockerTests
        }
    }
    "allure" {
        if (Test-DockerInstalled) {
            Generate-AllureReport
        }
    }
    "serve" {
        if (Test-DockerInstalled) {
            Start-AllureServer
        }
    }
    "full" {
        if (Test-DockerInstalled) {
            Build-DockerImage
            Run-DockerTests
            Generate-AllureReport
            Write-Success "Full test cycle completed!"
        }
    }
    "clean" {
        Write-Info "Cleaning up Docker containers and images..."
        docker container prune -f
        docker rmi alhouti-playwright -f 2>$null
        Write-Success "Cleanup completed"
    }
    default {
        Write-Error "Unknown action: $Action"
        Show-Help
    }
}
