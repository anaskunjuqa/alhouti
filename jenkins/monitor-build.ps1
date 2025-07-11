# Jenkins Build Monitor Script for Alhouti Playwright Tests (PowerShell)
# Usage: .\monitor-build.ps1 -JenkinsUrl "http://localhost:8080" -JobName "alhouti-playwright-tests" -BuildNumber "lastBuild" -Action "monitor"

param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JobName = "alhouti-playwright-tests", 
    [string]$BuildNumber = "lastBuild",
    [string]$Action = "monitor"
)

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colorMap = @{
        "Red" = "Red"
        "Green" = "Green" 
        "Yellow" = "Yellow"
        "Blue" = "Cyan"
        "White" = "White"
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

# Function to get build status
function Get-BuildStatus {
    param([string]$Url)
    
    try {
        $response = Invoke-RestMethod -Uri "$Url/api/json" -Method Get
        return $response.result
    }
    catch {
        return $null
    }
}

# Function to check if build is running
function Get-BuildProgress {
    param([string]$Url)
    
    try {
        $response = Invoke-RestMethod -Uri "$Url/api/json" -Method Get
        return $response.building
    }
    catch {
        return $false
    }
}

# Function to get console output
function Get-ConsoleOutput {
    param([string]$Url)
    
    try {
        $response = Invoke-WebRequest -Uri "$Url/consoleText" -Method Get
        return $response.Content
    }
    catch {
        return "Unable to fetch console output"
    }
}

# Function to display build information
function Show-BuildInfo {
    Write-ColorOutput "=== Jenkins Build Monitor ===" "Blue"
    Write-ColorOutput "Jenkins URL: $JenkinsUrl" "Blue"
    Write-ColorOutput "Job Name: $JobName" "Blue" 
    Write-ColorOutput "Build Number: $BuildNumber" "Blue"
    Write-ColorOutput "==============================" "Blue"
    Write-Host ""
}

# Function to check Jenkins connectivity
function Test-JenkinsConnection {
    Write-ColorOutput "🔌 Checking Jenkins connectivity..." "Blue"
    
    try {
        $response = Invoke-WebRequest -Uri $JenkinsUrl -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-ColorOutput "✅ Jenkins server is accessible" "Green"
            return $true
        }
    }
    catch {
        Write-ColorOutput "❌ Cannot connect to Jenkins server" "Red"
        Write-ColorOutput "Please check:" "Yellow"
        Write-Host "   - Jenkins URL: $JenkinsUrl"
        Write-Host "   - Network connectivity" 
        Write-Host "   - Jenkins server status"
        return $false
    }
}

# Function to monitor build in real-time
function Start-BuildMonitoring {
    $buildUrl = "$JenkinsUrl/job/$JobName/$BuildNumber"
    
    Write-ColorOutput "🔍 Monitoring build: $buildUrl" "Blue"
    Write-Host ""
    
    do {
        $status = Get-BuildStatus -Url $buildUrl
        $building = Get-BuildProgress -Url $buildUrl
        
        if ($building -eq $true) {
            Write-ColorOutput "⏳ Build is running..." "Yellow"
            Start-Sleep -Seconds 10
        }
        elseif ($status -eq "SUCCESS") {
            Write-ColorOutput "✅ Build completed successfully!" "Green"
            break
        }
        elseif ($status -eq "FAILURE") {
            Write-ColorOutput "❌ Build failed!" "Red"
            break
        }
        elseif ($status -eq "UNSTABLE") {
            Write-ColorOutput "⚠️  Build is unstable!" "Yellow"
            break
        }
        elseif ($status -eq "ABORTED") {
            Write-ColorOutput "🛑 Build was aborted!" "Yellow"
            break
        }
        else {
            $statusText = if ($status) { $status } else { "Unknown" }
            Write-ColorOutput "📊 Build status: $statusText" "Blue"
            Start-Sleep -Seconds 5
        }
    } while ($true)
    
    Write-Host ""
    Write-ColorOutput "📋 Final build status: $status" "Blue"
    
    # Show relevant URLs
    Write-Host ""
    Write-ColorOutput "🔗 Useful Links:" "Blue"
    Write-Host "   Build Details: $buildUrl"
    Write-Host "   Console Output: $buildUrl/console"
    Write-Host "   Allure Report: $buildUrl/allure"
    Write-Host "   Test Results: $buildUrl/testReport"
}

# Function to show recent console output
function Show-RecentLogs {
    $buildUrl = "$JenkinsUrl/job/$JobName/$BuildNumber"
    
    Write-ColorOutput "📝 Recent Console Output:" "Blue"
    Write-Host "----------------------------------------"
    
    $consoleOutput = Get-ConsoleOutput -Url $buildUrl
    $lines = $consoleOutput -split "`n"
    $recentLines = $lines | Select-Object -Last 20
    
    foreach ($line in $recentLines) {
        Write-Host $line
    }
    
    Write-Host "----------------------------------------"
}

# Function to list recent builds
function Show-RecentBuilds {
    Write-ColorOutput "📊 Recent Builds:" "Blue"
    
    try {
        $jobUrl = "$JenkinsUrl/job/$JobName/api/json"
        $response = Invoke-RestMethod -Uri $jobUrl -Method Get
        
        $recentBuilds = $response.builds | Select-Object -First 5
        
        foreach ($build in $recentBuilds) {
            $buildInfo = Invoke-RestMethod -Uri "$($build.url)api/json" -Method Get
            $buildNum = $buildInfo.number
            $status = $buildInfo.result
            
            if ($status -eq "SUCCESS") {
                Write-ColorOutput "  #$buildNum - ✅ $status" "Green"
            }
            elseif ($status -eq "FAILURE") {
                Write-ColorOutput "  #$buildNum - ❌ $status" "Red"
            }
            else {
                $statusText = if ($status) { $status } else { "RUNNING" }
                Write-ColorOutput "  #$buildNum - ⚠️  $statusText" "Yellow"
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to fetch recent builds" "Red"
    }
}

# Function to trigger a new build
function Start-NewBuild {
    Write-ColorOutput "🚀 Triggering new build..." "Blue"
    
    try {
        $triggerUrl = "$JenkinsUrl/job/$JobName/build"
        Invoke-WebRequest -Uri $triggerUrl -Method Post
        
        Write-ColorOutput "✅ Build triggered successfully!" "Green"
        Write-ColorOutput "⏳ Waiting for build to start..." "Blue"
        Start-Sleep -Seconds 5
        
        $script:BuildNumber = "lastBuild"
        Start-BuildMonitoring
    }
    catch {
        Write-ColorOutput "❌ Failed to trigger build" "Red"
        Write-Host $_.Exception.Message
    }
}

# Function to show current build status
function Show-BuildStatus {
    $buildUrl = "$JenkinsUrl/job/$JobName/$BuildNumber"
    $status = Get-BuildStatus -Url $buildUrl
    $statusText = if ($status) { $status } else { "Unknown" }
    
    Write-ColorOutput "Current build status: $statusText" "Blue"
}

# Main script execution
function Main {
    Show-BuildInfo
    
    if (-not (Test-JenkinsConnection)) {
        exit 1
    }
    
    switch ($Action.ToLower()) {
        "monitor" {
            Start-BuildMonitoring
        }
        "logs" {
            Show-RecentLogs
        }
        "list" {
            Show-RecentBuilds
        }
        "trigger" {
            Start-NewBuild
        }
        "status" {
            Show-BuildStatus
        }
        default {
            Write-Host "Usage: .\monitor-build.ps1 -JenkinsUrl <url> -JobName <name> -BuildNumber <number> -Action <action>"
            Write-Host ""
            Write-Host "Actions:"
            Write-Host "  monitor  - Monitor build progress (default)"
            Write-Host "  logs     - Show recent console output"
            Write-Host "  list     - List recent builds"
            Write-Host "  trigger  - Trigger a new build"
            Write-Host "  status   - Show current build status"
            Write-Host ""
            Write-Host "Examples:"
            Write-Host "  .\monitor-build.ps1                                    # Monitor last build on localhost"
            Write-Host "  .\monitor-build.ps1 -JenkinsUrl 'http://jenkins.company.com'  # Monitor on remote Jenkins"
            Write-Host "  .\monitor-build.ps1 -JobName 'my-job' -BuildNumber 42         # Monitor specific build"
            Write-Host "  .\monitor-build.ps1 -Action 'trigger'                         # Trigger new build"
        }
    }
}

# Execute main function
Main
