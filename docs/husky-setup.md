# Husky Git Hooks Configuration for Nuge

This document explains the Husky setup for the Nuge monorepo, which helps maintain code quality and
prevents CI pipeline failures by running automated checks before commits and pushes.

## Overview

Husky is configured with three main hooks:

1. **pre-commit**: Runs on every commit to format code, lint, and type-check staged files
2. **commit-msg**: Validates commit message format using conventional commits
3. **pre-push**: Runs comprehensive checks before pushing to prevent CI failures

## Pre-Commit Hook

### What it does:

- Formats and lints only the files you're committing (not the entire codebase)
- Auto-fixes formatting issues using Prettier
- Runs ESLint with auto-fix for JavaScript/TypeScript files
- Performs Python linting for API files (Black, isort, flake8, mypy)
- Runs type checking for TypeScript files

### Configuration:

The `.lintstagedrc.json` file defines what happens for different file types:

```json
{
  "mobile/**/*.{js,jsx,ts,tsx}": [
    "prettier --write",
    "npm run lint --workspace=mobile -- --fix --max-warnings=0"
  ],
  "web/**/*.{js,jsx,ts,tsx}": [
    "prettier --write",
    "npm run lint --workspace=web -- --fix --max-warnings=0"
  ],
  "shared/**/*.{js,jsx,ts,tsx}": ["prettier --write", "npm run type-check --workspace=shared"],
  "api/**/*.py": [
    "cd api && python -m black",
    "cd api && python -m isort",
    "cd api && python -m flake8",
    "cd api && python -m mypy"
  ]
}
```

### Example workflow:

1. Make changes to files
2. `git add <files>`
3. `git commit -m "your message"`
4. Hook automatically formats and lints your staged files
5. If issues are found, the commit is blocked with clear instructions

## Commit Message Hook

### What it does:

- Validates that commit messages follow conventional commit format
- Ensures consistent commit history for the team
- Supports custom types specific to the Nuge project

### Required format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Valid types:

- **General**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `ci`, `build`,
  `revert`
- **Workspace-specific**: `mobile`, `web`, `api`, `shared`, `db`, `deploy`

### Good examples:

```bash
feat(mobile): add geolocation for vendor search
fix(api): resolve user authentication issue
docs: update setup instructions in README
mobile: implement push notifications
web: add responsive design for tablet view
api: optimize database queries
```

### Bad examples:

```bash
update stuff
fix bug
WIP
added feature
```

## Pre-Push Hook

### What it does:

- Runs comprehensive checks to ensure code won't break CI
- Performs quick linting on changed files
- Runs TypeScript type checking
- Builds the project to ensure compilation
- Runs tests for feature branches (skips for main/develop)
- Performs Python-specific checks if API files changed

### Smart behavior:

- **Feature branches**: Runs full test suite
- **Main/develop branches**: Skips tests (assumes they went through PR process)
- **Python files changed**: Runs additional Python linting and type checking
- **Changed files only**: Uses Turbo's filtering to run checks only on affected files

### Performance optimizations:

- Uses `npm run lint:quick` and `npm run test:quick` for faster execution
- Leverages Turbo's caching and filtering capabilities
- Skips full test runs for main branches to avoid delays

## Bypassing Hooks (Emergency Use)

Sometimes you need to bypass hooks in exceptional circumstances:

### Skip pre-commit hook:

```bash
git commit --no-verify -m "emergency fix"
```

### Skip pre-push hook:

```bash
git push --no-verify
```

### Skip commit message validation:

```bash
git commit --no-verify -m "WIP: temporary commit"
```

**⚠️ Warning**: Only use `--no-verify` in true emergencies. It defeats the purpose of automated
quality checks.

## Troubleshooting

### Hook not running:

```bash
# Reinstall Husky hooks
npx husky install

# Check if hooks are executable
ls -la .husky/
```

### Lint-staged issues:

```bash
# Run lint-staged manually
npx lint-staged

# Check specific workspace
npm run lint --workspace=web
```

### Python environment issues:

```bash
# Ensure API environment is set up
cd api
uv sync
source venv/bin/activate  # or your venv activation method
```

### TypeScript issues:

```bash
# Run type checking manually
npm run type-check

# Check specific workspace
npm run type-check --workspace=shared
```

## Developer Workflow

### Normal development:

1. Create feature branch: `git checkout -b feat/new-feature`
2. Make changes
3. Stage files: `git add .`
4. Commit: `git commit -m "feat: add new feature"`
   - Pre-commit hook runs (formats, lints, type-checks)
   - Commit-msg hook validates message format
5. Push: `git push origin feat/new-feature`
   - Pre-push hook runs (comprehensive checks)

### If hooks fail:

1. Read the error message carefully
2. Follow the suggested fix steps
3. Make necessary corrections
4. Re-stage files if needed: `git add .`
5. Try the git operation again

## Performance Benefits

### Faster CI pipelines:

- Catches issues locally before they reach CI
- Reduces failed builds and red pipelines
- Saves development team time

### Better code quality:

- Consistent formatting across the entire team
- Standardized commit messages
- Type safety enforcement
- Linting issues caught early

### Team collaboration:

- Consistent code style reduces review friction
- Clear commit history aids debugging
- Prevents "formatting wars" in PRs

## Advanced Configuration

### Adding new file types:

Edit `.lintstagedrc.json` to include new patterns:

```json
{
  "*.scss": ["prettier --write"],
  "*.sql": ["sqlformat --reindent"]
}
```

### Customizing commit types:

Edit `.commitlintrc.json` to add new types:

```json
{
  "rules": {
    "type-enum": [
      2,
      "always",
      [
        "feat",
        "fix",
        "docs",
        "style",
        "refactor",
        "perf",
        "test",
        "chore",
        "ci",
        "build",
        "mobile",
        "web",
        "api",
        "shared",
        "db",
        "deploy",
        "analytics" // New custom type
      ]
    ]
  }
}
```

### Workspace-specific hooks:

You can add workspace-specific hook files in individual packages if needed, but the root-level hooks
should handle most cases.

## Integration with CI

The Husky hooks complement your CI pipeline:

1. **Local hooks**: Fast checks on committed/pushed code
2. **CI pipeline**: Comprehensive checks on the entire codebase including:
   - Full test suite
   - Build verification
   - Security scanning
   - Deployment checks

This two-layer approach ensures code quality while maintaining development velocity.

## Maintenance

### Updating dependencies:

```bash
# Update Husky
npm update husky

# Update lint-staged
npm update lint-staged

# Update commitlint
npm update @commitlint/cli @commitlint/config-conventional
```

### Adding new workspaces:

When adding new workspaces to the monorepo, update `.lintstagedrc.json` to include patterns for the
new workspace.

## Team Onboarding

For new team members:

1. Clone the repository
2. Run `npm install` (this runs `husky install` automatically via the `prepare` script)
3. Hooks are now active for all git operations
4. Read this documentation to understand the workflow

The hooks will guide new developers with clear error messages and fix suggestions, making onboarding
smoother and ensuring code quality from day one.
