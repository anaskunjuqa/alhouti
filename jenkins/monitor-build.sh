#!/bin/bash

# Jenkins Build Monitor Script for Alhouti Playwright Tests
# Usage: ./monitor-build.sh [JENKINS_URL] [JOB_NAME] [BUILD_NUMBER]

set -e

# Default values
JENKINS_URL=${1:-"http://localhost:8080"}
JOB_NAME=${2:-"alhouti-playwright-tests"}
BUILD_NUMBER=${3:-"lastBuild"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to get build status
get_build_status() {
    local url="${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/api/json"
    curl -s "${url}" | grep -o '"result":"[^"]*"' | cut -d'"' -f4
}

# Function to get build progress
get_build_progress() {
    local url="${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/api/json"
    local building=$(curl -s "${url}" | grep -o '"building":[^,]*' | cut -d':' -f2)
    echo $building
}

# Function to get console output
get_console_output() {
    local url="${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/consoleText"
    curl -s "${url}"
}

# Function to display build information
show_build_info() {
    print_status $BLUE "=== Jenkins Build Monitor ==="
    print_status $BLUE "Jenkins URL: ${JENKINS_URL}"
    print_status $BLUE "Job Name: ${JOB_NAME}"
    print_status $BLUE "Build Number: ${BUILD_NUMBER}"
    print_status $BLUE "=============================="
    echo
}

# Function to monitor build in real-time
monitor_build() {
    local build_url="${JENKINS_URL}/job/${JOB_NAME}/${BUILD_NUMBER}/"
    
    print_status $BLUE "🔍 Monitoring build: ${build_url}"
    echo
    
    while true; do
        local status=$(get_build_status)
        local building=$(get_build_progress)
        
        if [ "$building" = "true" ]; then
            print_status $YELLOW "⏳ Build is running..."
            sleep 10
        elif [ "$status" = "SUCCESS" ]; then
            print_status $GREEN "✅ Build completed successfully!"
            break
        elif [ "$status" = "FAILURE" ]; then
            print_status $RED "❌ Build failed!"
            break
        elif [ "$status" = "UNSTABLE" ]; then
            print_status $YELLOW "⚠️  Build is unstable!"
            break
        elif [ "$status" = "ABORTED" ]; then
            print_status $YELLOW "🛑 Build was aborted!"
            break
        else
            print_status $BLUE "📊 Build status: ${status:-"Unknown"}"
            sleep 5
        fi
    done
    
    echo
    print_status $BLUE "📋 Final build status: ${status}"
    
    # Show relevant URLs
    echo
    print_status $BLUE "🔗 Useful Links:"
    echo "   Build Details: ${build_url}"
    echo "   Console Output: ${build_url}console"
    echo "   Allure Report: ${build_url}allure"
    echo "   Test Results: ${build_url}testReport"
}

# Function to show recent console output
show_recent_logs() {
    print_status $BLUE "📝 Recent Console Output:"
    echo "----------------------------------------"
    get_console_output | tail -20
    echo "----------------------------------------"
}

# Function to check Jenkins connectivity
check_jenkins() {
    print_status $BLUE "🔌 Checking Jenkins connectivity..."
    
    if curl -s --head "${JENKINS_URL}" | head -n 1 | grep -q "200 OK"; then
        print_status $GREEN "✅ Jenkins server is accessible"
    else
        print_status $RED "❌ Cannot connect to Jenkins server"
        print_status $YELLOW "Please check:"
        echo "   - Jenkins URL: ${JENKINS_URL}"
        echo "   - Network connectivity"
        echo "   - Jenkins server status"
        exit 1
    fi
}

# Function to list recent builds
list_recent_builds() {
    print_status $BLUE "📊 Recent Builds:"
    local url="${JENKINS_URL}/job/${JOB_NAME}/api/json"
    
    curl -s "${url}" | grep -o '"number":[0-9]*' | head -5 | while read build; do
        local num=$(echo $build | cut -d':' -f2)
        local build_url="${JENKINS_URL}/job/${JOB_NAME}/${num}/api/json"
        local status=$(curl -s "${build_url}" | grep -o '"result":"[^"]*"' | cut -d'"' -f4)
        local timestamp=$(curl -s "${build_url}" | grep -o '"timestamp":[0-9]*' | cut -d':' -f2)
        
        if [ "$status" = "SUCCESS" ]; then
            print_status $GREEN "  #${num} - ✅ ${status}"
        elif [ "$status" = "FAILURE" ]; then
            print_status $RED "  #${num} - ❌ ${status}"
        else
            print_status $YELLOW "  #${num} - ⚠️  ${status:-"RUNNING"}"
        fi
    done
}

# Function to trigger a new build
trigger_build() {
    print_status $BLUE "🚀 Triggering new build..."
    local trigger_url="${JENKINS_URL}/job/${JOB_NAME}/build"
    
    if curl -s -X POST "${trigger_url}"; then
        print_status $GREEN "✅ Build triggered successfully!"
        print_status $BLUE "⏳ Waiting for build to start..."
        sleep 5
        BUILD_NUMBER="lastBuild"
        monitor_build
    else
        print_status $RED "❌ Failed to trigger build"
    fi
}

# Main script logic
main() {
    show_build_info
    check_jenkins
    
    case "${4:-monitor}" in
        "monitor")
            monitor_build
            ;;
        "logs")
            show_recent_logs
            ;;
        "list")
            list_recent_builds
            ;;
        "trigger")
            trigger_build
            ;;
        "status")
            local status=$(get_build_status)
            print_status $BLUE "Current build status: ${status:-"Unknown"}"
            ;;
        *)
            echo "Usage: $0 [JENKINS_URL] [JOB_NAME] [BUILD_NUMBER] [ACTION]"
            echo ""
            echo "Actions:"
            echo "  monitor  - Monitor build progress (default)"
            echo "  logs     - Show recent console output"
            echo "  list     - List recent builds"
            echo "  trigger  - Trigger a new build"
            echo "  status   - Show current build status"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Monitor last build on localhost"
            echo "  $0 http://jenkins.company.com        # Monitor on remote Jenkins"
            echo "  $0 http://localhost:8080 my-job 42   # Monitor specific build"
            echo "  $0 http://localhost:8080 my-job lastBuild trigger  # Trigger new build"
            ;;
    esac
}

# Run the script
main "$@"
