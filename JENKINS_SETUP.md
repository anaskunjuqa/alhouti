# Jenkins CI/CD Pipeline Setup for Alhouti Playwright Automation

This document provides step-by-step instructions to set up a Jenkins CI/CD pipeline for the Alhouti Playwright automation framework.

## Prerequisites

### 1. Jenkins Server Requirements
- Jenkins 2.400+ installed
- Java 11 or higher
- Minimum 4GB RAM, 8GB recommended
- Docker (optional, for containerized builds)

### 2. Required Jenkins Plugins
Install these plugins in Jenkins (Manage Jenkins → Manage Plugins):

**Essential Plugins:**
- Pipeline
- Git
- NodeJS
- Allure Jenkins Plugin
- Email Extension Plugin
- Build Timeout
- Timestamper
- Workspace Cleanup

**Optional but Recommended:**
- Blue Ocean (for better pipeline visualization)
- Slack Notification (if using Slack)
- GitHub Integration Plugin
- Pipeline: Stage View

## Jenkins Setup Steps

### Step 1: Configure Global Tools

1. **Go to:** Manage Jenkins → Global Tool Configuration

2. **Configure NodeJS:**
   - Click "Add NodeJS"
   - Name: `Node18` (or your preferred name)
   - Version: `18.x.x` (latest LTS)
   - Check "Install automatically"

3. **Configure Git:**
   - Usually auto-detected
   - Verify Git is available

### Step 2: Create New Pipeline Job

1. **Create Job:**
   - Click "New Item"
   - Enter name: `alhouti-playwright-tests`
   - Select "Pipeline"
   - Click "OK"

2. **Configure Pipeline:**
   - **General Tab:**
     - Description: "Playwright automation tests for Alhouti website"
     - Check "GitHub project" and enter: `https://github.com/anaskunjuqa/alhouti`
   
   - **Build Triggers:**
     - Check "GitHub hook trigger for GITScm polling" (for webhook)
     - Check "Poll SCM" with schedule: `H/5 * * * *` (every 5 minutes as backup)
   
   - **Pipeline Section:**
     - Definition: "Pipeline script from SCM"
     - SCM: Git
     - Repository URL: `https://github.com/anaskunjuqa/alhouti.git`
     - Branch: `*/main`
     - Script Path: `Jenkinsfile`

### Step 3: Configure GitHub Webhook (Optional)

1. **In GitHub Repository:**
   - Go to Settings → Webhooks
   - Click "Add webhook"
   - Payload URL: `http://your-jenkins-url/github-webhook/`
   - Content type: `application/json`
   - Events: "Just the push event"

2. **Test Connection:**
   - Push a commit to trigger the pipeline

### Step 4: Configure Email Notifications

1. **Go to:** Manage Jenkins → Configure System

2. **Email Configuration:**
   - SMTP Server: Your email provider's SMTP
   - Default user e-mail suffix: `@yourcompany.com`
   - Configure authentication if required

3. **Extended E-mail Notification:**
   - Configure SMTP settings
   - Set default recipients
   - Configure email templates

## Pipeline Features

### 🔄 **Automated Stages:**

1. **Checkout:** Pulls latest code from GitHub
2. **Install Dependencies:** Runs `npm ci` for clean install
3. **Install Playwright Browsers:** Downloads required browser binaries
4. **Code Quality:** Runs linting (if configured)
5. **Run Tests:** Executes Playwright tests
6. **Generate Reports:** Creates Allure test reports
7. **Publish Results:** Makes reports available in Jenkins
8. **Deploy:** Deploys to test environment (main branch only)

### 📊 **Reporting:**
- **Allure Reports:** Interactive test reports with screenshots
- **Artifacts:** Test results, screenshots, videos archived
- **Email Notifications:** Success/failure notifications
- **Console Logs:** Detailed build logs

### 🚀 **Triggers:**
- **Push to main:** Full pipeline execution
- **Pull Requests:** Test validation
- **Scheduled:** Nightly regression tests
- **Manual:** On-demand execution

## Environment Variables

The pipeline uses these environment variables:

```bash
NODE_VERSION=18                           # Node.js version
PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright  # Browser cache location
```

## Customization Options

### 1. Add Environment-Specific Tests
```groovy
stage('Test Staging') {
    when { branch 'staging' }
    steps {
        sh 'npm run test:staging'
    }
}
```

### 2. Parallel Test Execution
```groovy
stage('Parallel Tests') {
    parallel {
        stage('Chrome Tests') {
            steps { sh 'npx playwright test --project=chromium' }
        }
        stage('Firefox Tests') {
            steps { sh 'npx playwright test --project=firefox' }
        }
    }
}
```

### 3. Slack Notifications
```groovy
post {
    success {
        slackSend channel: '#qa-team', 
                  color: 'good', 
                  message: "✅ Tests passed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
    }
}
```

## Troubleshooting

### Common Issues:

1. **Browser Installation Fails:**
   - Ensure sufficient disk space
   - Check internet connectivity
   - Verify permissions

2. **Tests Timeout:**
   - Increase timeout in `playwright.config.ts`
   - Add build timeout in Jenkins job configuration

3. **Permission Issues:**
   - Ensure Jenkins user has proper permissions
   - Check file ownership in workspace

4. **Memory Issues:**
   - Increase Jenkins heap size
   - Limit parallel test execution

## Monitoring and Maintenance

### Regular Tasks:
- Monitor disk space (browser cache grows over time)
- Update Playwright version regularly
- Review and archive old build artifacts
- Monitor test execution times

### Performance Optimization:
- Use Jenkins agents for distributed builds
- Cache node_modules between builds
- Optimize test parallelization
- Regular cleanup of old builds

## Security Considerations

1. **Credentials Management:**
   - Use Jenkins Credentials Store
   - Never hardcode secrets in Jenkinsfile
   - Rotate access tokens regularly

2. **Access Control:**
   - Configure proper user permissions
   - Use role-based access control
   - Audit user activities

## Next Steps

1. Set up the Jenkins pipeline using this configuration
2. Test the pipeline with a sample commit
3. Configure notifications and reporting
4. Set up monitoring and alerting
5. Train team members on pipeline usage

For support or questions, refer to the Jenkins documentation or contact the DevOps team.
