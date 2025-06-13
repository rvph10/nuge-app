# 🐕 Husky Quick Reference for Nuge

## Common Commands

### Fix formatting issues:

```bash
npm run format              # Format all files
npm run format:quick        # Format only staged files (lint-staged)
```

### Manual linting:

```bash
npm run lint                # Lint all workspaces
npm run lint:quick          # Lint only changed files
npm run lint -- --fix      # Auto-fix linting issues
```

### Type checking:

```bash
npm run type-check          # Check all workspaces
npm run shared:type-check   # Check only shared workspace
```

### Testing:

```bash
npm run test                # Run all tests
npm run test:quick          # Run tests for changed files only
```

## Emergency Bypasses

### Skip all hooks:

```bash
git commit --no-verify -m "emergency fix"
git push --no-verify
```

### Skip only commit message validation:

```bash
git commit --no-verify -m "WIP: temporary work"
```

## Valid Commit Message Examples

### General types:

```bash
feat: add new user authentication
fix: resolve memory leak in vendor search
docs: update API documentation
test: add unit tests for geolocation
chore: update dependencies
```

### Workspace-specific:

```bash
mobile: implement push notifications
web: add responsive design for tablets
api: optimize database connection pooling
shared: add new utility functions
db: create vendor rating migration
```

## Quick Troubleshooting

### Hook not running?

```bash
npx husky install
chmod +x .husky/*
```

### Lint-staged failing?

```bash
npx lint-staged --debug
npm run format:quick
```

### TypeScript errors?

```bash
npm run type-check
# Fix errors, then:
git add .
git commit -m "fix: resolve typescript errors"
```

### Python API issues?

```bash
cd api
python -m black src/
python -m isort src/
python -m flake8 src/
python -m mypy src/
```

## What Each Hook Does

### Pre-commit (Fast - runs on staged files only):

- ✅ Format code with Prettier
- ✅ Fix ESLint issues
- ✅ Type-check TypeScript
- ✅ Format Python with Black/isort
- ✅ Run Python linting (flake8, mypy)

### Commit-msg:

- ✅ Validate commit message format
- ✅ Ensure conventional commits

### Pre-push (Comprehensive - prevents CI failures):

- ✅ Quick lint check on changed files
- ✅ Full TypeScript type checking
- ✅ Build verification
- ✅ Test suite (feature branches only)
- ✅ Python quality checks (if API changed)

## Performance Tips

- Hooks use Turbo's filtering to run only on affected files/workspaces
- Pre-push skips tests on main/develop branches (they go through PR)
- Lint-staged only processes files you're actually committing
- Build cache is leveraged for faster subsequent runs

## Need Help?

1. Read the error message carefully - they include fix instructions
2. Check `docs/husky-setup.md` for detailed documentation
3. Ask team members in Slack
4. As last resort: use `--no-verify` (but fix issues in next commit!)

---

_Remember: These hooks exist to help us maintain code quality and prevent CI failures. They're your
friends! 🚀_
