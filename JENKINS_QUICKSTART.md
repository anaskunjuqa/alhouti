# 🚀 Jenkins Quick Start Guide - Run Alhouti Playwright Tests

This guide will help you quickly set up and run your Playwright automation tests in Jenkins.

## 🎯 Quick Setup (5 Minutes)

### Option 1: Local Jenkins (Fastest)

1. **Download Jenkins:**
   ```bash
   # Download Jenkins WAR file
   wget https://get.jenkins.io/war-stable/latest/jenkins.war
   
   # Or use curl
   curl -O https://get.jenkins.io/war-stable/latest/jenkins.war
   ```

2. **Start Jenkins:**
   ```bash
   java -jar jenkins.war --httpPort=8080
   ```

3. **Access Jenkins:**
   - Open browser: `http://localhost:8080`
   - Follow setup wizard
   - Install suggested plugins

### Option 2: Docker Jenkins (Recommended)

```bash
# Run Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

## ⚡ Quick Job Setup

### 1. Create Pipeline Job

1. **New Item** → Enter name: `alhouti-playwright-tests`
2. **Select "Pipeline"** → Click OK
3. **Pipeline Section:**
   - Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/anaskunjuqa/alhouti.git`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
4. **Save**

### 2. Install Required Plugins

**Manage Jenkins** → **Manage Plugins** → **Available**

Search and install:
- ✅ Pipeline
- ✅ Git
- ✅ NodeJS
- ✅ Allure Jenkins Plugin

### 3. Configure NodeJS

**Manage Jenkins** → **Global Tool Configuration**

1. **NodeJS** section → **Add NodeJS**
2. Name: `Node18`
3. Version: `18.x.x` (latest LTS)
4. ✅ Install automatically
5. **Save**

## 🏃‍♂️ Run Your Tests

### Method 1: Manual Trigger

1. Go to your job: `alhouti-playwright-tests`
2. Click **"Build Now"**
3. Watch the build progress

### Method 2: Using Monitor Scripts

**Linux/Mac:**
```bash
# Make script executable
chmod +x jenkins/monitor-build.sh

# Monitor build
./jenkins/monitor-build.sh

# Trigger new build
./jenkins/monitor-build.sh http://localhost:8080 alhouti-playwright-tests lastBuild trigger
```

**Windows:**
```powershell
# Monitor build
.\jenkins\monitor-build.ps1

# Trigger new build
.\jenkins\monitor-build.ps1 -Action "trigger"
```

## 📊 View Results

After build completion, check:

1. **Console Output:** `http://localhost:8080/job/alhouti-playwright-tests/lastBuild/console`
2. **Allure Report:** `http://localhost:8080/job/alhouti-playwright-tests/lastBuild/allure`
3. **Test Results:** `http://localhost:8080/job/alhouti-playwright-tests/lastBuild/testReport`

## 🔧 Troubleshooting

### Common Issues:

#### ❌ "Node not found"
**Solution:** Configure NodeJS in Global Tool Configuration

#### ❌ "Playwright browsers not installed"
**Solution:** The pipeline automatically installs browsers. If it fails:
```bash
# Manual installation
npx playwright install --with-deps
```

#### ❌ "Permission denied"
**Solution:** Ensure Jenkins has proper permissions:
```bash
# Fix permissions (Linux/Mac)
sudo chown -R jenkins:jenkins /var/jenkins_home
```

#### ❌ "Tests timeout"
**Solution:** Increase timeout in `playwright.config.ts`:
```javascript
export default defineConfig({
  timeout: 60 * 1000, // 60 seconds
  // ...
});
```

### Build Logs Analysis:

**Look for these key stages:**
1. ✅ Checkout - Code pulled successfully
2. ✅ Install Dependencies - `npm ci` completed
3. ✅ Install Playwright Browsers - Browsers downloaded
4. ✅ Run Tests - Tests executed
5. ✅ Generate Reports - Allure report created

## 🎛️ Advanced Configuration

### Parameterized Builds

Use `jenkins/Jenkinsfile.multibranch` for advanced features:

1. **Environment selection** (dev, staging, production)
2. **Browser selection** (chromium, firefox, webkit, all)
3. **Headless/headed mode**
4. **Report generation toggle**

### Scheduled Runs

Add to job configuration:
```
# Run every night at 2 AM
H 2 * * *

# Run every hour during business hours
H 9-17 * * 1-5
```

### Webhook Integration

1. **GitHub Settings** → **Webhooks** → **Add webhook**
2. **Payload URL:** `http://your-jenkins-url/github-webhook/`
3. **Content type:** `application/json`
4. **Events:** Just the push event

## 📈 Monitoring & Alerts

### Email Notifications

Configure in **Manage Jenkins** → **Configure System**:

1. **E-mail Notification** section
2. SMTP server: `smtp.gmail.com`
3. Port: `587`
4. Use SSL: ✅
5. Username/Password: Your credentials

### Slack Integration

1. Install **Slack Notification Plugin**
2. Configure Slack workspace
3. Add webhook URL in Jenkins configuration

## 🚀 Production Deployment

### Multi-Environment Pipeline

```groovy
stage('Deploy to Staging') {
    when { branch 'main' }
    steps {
        // Deploy to staging environment
        sh 'npm run deploy:staging'
    }
}

stage('Deploy to Production') {
    when { 
        branch 'main'
        expression { currentBuild.result == 'SUCCESS' }
    }
    input {
        message "Deploy to production?"
        ok "Deploy"
    }
    steps {
        sh 'npm run deploy:production'
    }
}
```

## 📋 Checklist

Before running in production:

- [ ] Jenkins server properly configured
- [ ] Required plugins installed
- [ ] NodeJS configured
- [ ] Git credentials set up
- [ ] Webhook configured (optional)
- [ ] Email notifications configured
- [ ] Test job created and tested
- [ ] Allure reporting working
- [ ] Build artifacts archived
- [ ] Quality gates configured

## 🆘 Getting Help

1. **Check Jenkins logs:** `http://localhost:8080/log/all`
2. **Console output:** Available in each build
3. **Jenkins documentation:** https://www.jenkins.io/doc/
4. **Playwright documentation:** https://playwright.dev/

## 🎉 Success Indicators

Your setup is working correctly when you see:

✅ **Green build status**
✅ **Allure report generated**
✅ **Test artifacts archived**
✅ **Email notifications sent**
✅ **Console shows all stages passed**

---

**🎊 Congratulations! Your Playwright tests are now running in Jenkins!**

For advanced configuration and troubleshooting, refer to the complete `JENKINS_SETUP.md` guide.
