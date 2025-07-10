pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
        PLAYWRIGHT_BROWSERS_PATH = '/opt/ms-playwright'
    }
    
    tools {
        nodejs "${NODE_VERSION}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from repository...'
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }
        
        stage('Install Playwright Browsers') {
            steps {
                echo 'Installing Playwright browsers...'
                sh 'npx playwright install --with-deps'
            }
        }
        
        stage('Run Lint/Code Quality') {
            steps {
                echo 'Running code quality checks...'
                script {
                    try {
                        sh 'npm run lint || echo "Lint not configured, skipping..."'
                    } catch (Exception e) {
                        echo "Lint step failed or not configured: ${e.getMessage()}"
                    }
                }
            }
        }
        
        stage('Run Playwright Tests') {
            steps {
                echo 'Running Playwright tests...'
                sh 'npx playwright test'
            }
            post {
                always {
                    // Archive test results
                    archiveArtifacts artifacts: 'test-results/**/*', allowEmptyArchive: true
                    archiveArtifacts artifacts: 'playwright-report/**/*', allowEmptyArchive: true
                }
            }
        }
        
        stage('Generate Allure Report') {
            steps {
                echo 'Generating Allure report...'
                sh 'npm run allure:generate'
            }
            post {
                always {
                    // Archive Allure results
                    archiveArtifacts artifacts: 'allure-results/**/*', allowEmptyArchive: true
                    archiveArtifacts artifacts: 'allure-report/**/*', allowEmptyArchive: true
                }
            }
        }
        
        stage('Publish Test Results') {
            steps {
                echo 'Publishing test results...'
                script {
                    // Publish Allure report
                    allure([
                        includeProperties: false,
                        jdk: '',
                        properties: [],
                        reportBuildPolicy: 'ALWAYS',
                        results: [[path: 'allure-results']]
                    ])
                }
            }
        }
        
        stage('Deploy to Test Environment') {
            when {
                branch 'main'
            }
            steps {
                echo 'Deploying to test environment...'
                script {
                    // Add your deployment steps here
                    echo 'Deployment steps would go here'
                    // Example: sh 'npm run deploy:test'
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed!'
            // Clean up workspace if needed
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded! ✅'
            // Send success notifications
            script {
                try {
                    emailext (
                        subject: "✅ Jenkins Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                        body: """
                        <h2>Build Successful! ✅</h2>
                        <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                        <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                        <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                        <p><strong>Test Report:</strong> <a href="${env.BUILD_URL}allure">View Allure Report</a></p>
                        """,
                        to: "${env.CHANGE_AUTHOR_EMAIL ?: 'team@example.com'}",
                        mimeType: 'text/html'
                    )
                } catch (Exception e) {
                    echo "Email notification failed: ${e.getMessage()}"
                }
            }
        }
        failure {
            echo 'Pipeline failed! ❌'
            // Send failure notifications
            script {
                try {
                    emailext (
                        subject: "❌ Jenkins Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                        body: """
                        <h2>Build Failed! ❌</h2>
                        <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                        <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                        <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                        <p><strong>Console Output:</strong> <a href="${env.BUILD_URL}console">View Console</a></p>
                        """,
                        to: "${env.CHANGE_AUTHOR_EMAIL ?: 'team@example.com'}",
                        mimeType: 'text/html'
                    )
                } catch (Exception e) {
                    echo "Email notification failed: ${e.getMessage()}"
                }
            }
        }
        unstable {
            echo 'Pipeline is unstable! ⚠️'
        }
    }
}
