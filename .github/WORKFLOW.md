# GitHub Flow Workflow

## Branch Strategy
- **main**: Production-ready code (default branch)
- **feature branches**: Feature development (feature/*, bugfix/*, etc.)
- **hotfix branches**: Emergency production fixes (hotfix/*)

## Typical Workflow

### Starting New Feature
```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature-name
# Make changes and commit
git push origin feature/your-feature-name
```

### Creating a Pull Request
1. Go to GitHub repository
2. Create Pull Request from feature branch to main
3. Add description and reference any issues
4. Request reviewers
5. Address any feedback

### Merging Pull Request
1. Ensure all checks pass
2. Get approval from reviewers
3. Merge with 'Create a merge commit' option (maintains history)
4. Delete the feature branch
5. Pull latest changes: git pull origin main

### After Review and Merge
```bash
git checkout main
git pull origin main
# Your changes are now in main
```

## Commit Message Guidelines

Use clear, descriptive commit messages:
- Start with a verb: 'Add', 'Fix', 'Update', 'Remove', 'Refactor'
- First line: max 50 characters
- Body: wrap at 72 characters
- Reference issues: 'Fixes #123'

Example:
```
Add data validation function

- Validates input parameters
- Handles edge cases
- Includes unit tests

Fixes #456
```

## Release Process

When ready to release:
1. Create a release branch from main
2. Update version numbers
3. Create a release on GitHub
4. Tag the commit: git tag v1.0.0
5. Push tags: git push origin --tags

## Protecting main Branch (GitHub Settings)

1. Go to Settings > Branches
2. Add rule for 'main':
   - Require pull request reviews
   - Dismiss stale PR approvals
   - Require status checks to pass
   - Restrict who can push

