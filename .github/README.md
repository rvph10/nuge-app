# CI/CD Pipeline Documentation

This directory contains the GitHub Actions workflows for the Nuge App monorepo. The CI/CD pipeline
is designed to handle a complex project structure with multiple components.

## Project Structure

- **Mobile App**: Expo/React Native application (`mobile/`)
- **Web App**: Next.js application (`web/`)
- **Backend API**: FastAPI with Supabase (`api/`)
- **Shared Code**: TypeScript utilities and types (`shared/`)

## Workflows Overview

### 1. CI Workflow (`.github/workflows/ci.yml`)

**Trigger**: Push/PR to `main` or `develop` branches

**Purpose**: Comprehensive code quality and build verification

**Jobs**:

- **Install Dependencies**: Sets up caching for Node.js and Python dependencies
- **Code Quality (TS/JS)**: Runs formatting, linting, and type checking for TypeScript/JavaScript
  code
- **Build Verification**: Builds web and shared packages to ensure they compile
- **Mobile App (Expo)**: Validates Expo configuration and mobile-specific checks
- **Backend (FastAPI)**: Python linting, type checking, and testing
- **Tests**: Runs test suites (currently disabled, enable when tests are added)
- **CI Success**: Final status check that ensures all jobs passed

**Key Features**:

- ✅ Parallel execution for faster builds
- ✅ Intelligent caching for dependencies
- ✅ Turbo monorepo support
- ✅ Multi-language support (TypeScript, Python)
- ✅ Mobile-specific validations

### 2. Deploy Workflow (`.github/workflows/deploy.yml`)

**Trigger**:

- Push to `main` (staging deployment)
- Manual workflow dispatch with environment selection

**Purpose**: Automated staging deployment with testing

**Jobs**:

- **Setup Deployment**: Determines environment and checks for changes
- **Deploy Web App**: Deploys Next.js app to Vercel (staging)
- **Deploy API**: Deploys FastAPI backend to Railway (staging)
- **Staging Tests**: Runs integration tests against staging environment
- **Deployment Summary**: Creates comprehensive deployment report

**Key Features**:

- ✅ Smart change detection (only deploy what changed)
- ✅ Railway integration for API deployment
- ✅ Vercel integration for web app deployment
- ✅ Automated staging tests before production eligibility

### 3. Production Deploy Workflow (`.github/workflows/production-deploy.yml`)

**Trigger**: Manual workflow dispatch only (requires confirmation)

**Purpose**: Secure production deployment with verification

**Jobs**:

- **Verify**: Requires manual confirmation ("DEPLOY" input)
- **Deploy Web App (Production)**: Deploys to Vercel production
- **Deploy API (Production)**: Deploys to Railway production
- **Production Tests**: Runs smoke tests against production
- **Production Summary**: Creates deployment report with live URLs

**Key Features**:

- ✅ Manual confirmation required
- ✅ Production smoke tests
- ✅ Comprehensive deployment verification
- ✅ Live URL validation

### 4. Security Workflow (`.github/workflows/security.yml`)

**Trigger**:

- Weekly schedule (Mondays at 9 AM UTC)
- Changes to dependency files
- Manual workflow dispatch

**Purpose**: Security scanning and dependency management

**Jobs**:

- **NPM Security Audit**: Scans for vulnerabilities in Node.js dependencies
- **Python Security Audit**: Scans Python dependencies with Safety
- **License Compliance**: Ensures all dependencies use approved licenses
- **Outdated Dependencies**: Reports outdated packages
- **CodeQL Analysis**: Advanced security analysis for JavaScript and Python
- **Security Summary**: Consolidated security report

**Key Features**:

- ✅ Multi-language security scanning
- ✅ License compliance monitoring
- ✅ Automated vulnerability detection
- ✅ Regular scheduled scans

## Setup Instructions

### 1. Repository Secrets

Add the following secrets to your GitHub repository (`Settings > Secrets and variables > Actions`):

#### For Web Deployment (Vercel)

```
VERCEL_TOKEN=your_vercel_token
VERCEL_ORG_ID=your_vercel_org_id
VERCEL_PROJECT_ID=your_vercel_project_id
```

#### For Mobile Deployment (Expo)

```
EXPO_TOKEN=your_expo_access_token
```

#### For API Deployment (Railway)

```
RAILWAY_TOKEN=your_railway_token
```

#### For Staging/Production Testing

```
STAGING_API_URL=https://nuge-api-staging.railway.app
STAGING_WEB_URL=https://nuge-staging.vercel.app
PRODUCTION_API_URL=https://nuge-api-production.railway.app
PRODUCTION_WEB_URL=https://nuge.vercel.app
```

### 2. Environment Configuration

Create GitHub environments for different deployment stages:

1. Go to `Settings > Environments`
2. Create environments: `staging` and `production`
3. Add environment-specific variables and protection rules

### 3. Branch Protection Rules

Recommended branch protection settings for `main`:

1. Go to `Settings > Branches`
2. Add rule for `main` branch:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Require conversation resolution before merging
   - ✅ Include administrators

Required status checks:

- `CI Success`
- `Code Quality (TS/JS)`
- `Build Verification`
- `Mobile App (Expo)`
- `Backend (FastAPI)`

### 4. Customizing Deployments

#### Deployment Process

The deployment follows a **staging-first** approach:

1. **Staging Deployment** (automatic on `main` push):

   - Web app deployed to Vercel staging
   - API deployed to Railway staging
   - Integration tests run against staging environment

2. **Production Deployment** (manual trigger):
   - Navigate to Actions > Production Deploy
   - Enter "DEPLOY" to confirm
   - Deploys to production environments
   - Runs smoke tests against production

#### Railway Setup

Ensure you have two Railway services configured:

- `nuge-api-staging` - for staging environment
- `nuge-api-production` - for production environment

#### Vercel Setup

Configure Vercel with appropriate staging and production environments linked to your repository.

### 5. Enabling Tests

Currently, the test job is disabled. To enable:

1. Add test scripts to your package.json files
2. Create test files
3. Change `if: false` to `if: true` in the test job

## Monitoring and Maintenance

### Workflow Status

- Monitor workflow runs in the `Actions` tab
- Set up notifications for failed workflows
- Review security scan results weekly

### Dependencies

- Review outdated dependency reports
- Update dependencies regularly
- Monitor security advisories

### Performance

- Check workflow execution times
- Optimize caching strategies
- Review parallel job execution

## Troubleshooting

### Common Issues

1. **Cache Issues**: Clear cache by adding `/clear-cache` to commit message
2. **Permission Errors**: Ensure secrets are correctly configured
3. **Build Failures**: Check dependency compatibility and versions
4. **Deployment Failures**: Verify environment configurations

### Debugging

1. Enable debug logging by setting `ACTIONS_STEP_DEBUG=true` secret
2. Use workflow dispatch for manual testing
3. Check individual job logs for detailed error messages

## Contributing

When adding new features:

1. Update relevant workflows
2. Test changes in a feature branch
3. Update this documentation
4. Ensure all checks pass before merging

## Security Considerations

- Regularly review and rotate secrets
- Monitor security scan results
- Keep dependencies updated
- Use least privilege access for deployment tokens
- Enable branch protection rules

---

For questions or issues with the CI/CD pipeline, please create an issue or contact the development
team.
