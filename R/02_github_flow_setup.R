# GitHub Flow Branching Strategy Setup
# This script sets up the GitHub Flow workflow with main and develop branches
# Usage: source("R/02_github_flow_setup.R")

# ============================================================================
# GitHub Flow Overview:
# 
# main (or master):
#   - Production-ready code
#   - All commits must be tested and reviewed
#   - Tags mark releases
#
# Feature branches:
#   - Created from 'main': git checkout -b feature/feature-name
#   - Work on feature
#   - Create Pull Request (PR) for review
#   - After approval and tests pass, merge to main
#   - Delete feature branch
#
# Hotfix branches (optional):
#   - For urgent production fixes
#   - Created from 'main': git checkout -b hotfix/hotfix-name
#   - Fix the issue
#   - PR, review, merge to main
#   - Merge back to develop if exists
# ============================================================================

cat("\n========================================\n")
cat("    GitHub Flow Setup Configuration\n")
cat("========================================\n")

# ============================================================================
# Step 1: Verify current branch is 'main'
# ============================================================================
cat("\n=== Step 1: Checking current branch ===\n")

current_branch <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)
cat(sprintf("Current branch: %s\n", current_branch))

if (current_branch != "main") {
  cat("! Current branch is not 'main'\n")
  cat("Run: git checkout main\n")
}

# ============================================================================
# Step 2: GitHub Flow Workflow Documentation
# ============================================================================
cat("\n=== Step 2: GitHub Flow Workflow ===\n")

workflow_content <- "# GitHub Flow Workflow

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
"

writeLines(workflow_content, ".github/WORKFLOW.md")
cat("✓ Created .github/WORKFLOW.md with GitHub Flow documentation\n")

# ============================================================================
# Step 3: Create branch protection rules documentation
# ============================================================================
cat("\n=== Step 3: Branch Protection Setup ===\n")

protection_content <- "# Branch Protection Rules for GitHub Flow

## Setting Up Protection for 'main' Branch

### Steps on GitHub:
1. Go to Repository Settings > Branches
2. Add branch protection rule for 'main':
   - Check: 'Require a pull request before merging'
   - Check: 'Require status checks to pass before merging'
   - Check: 'Require branches to be up to date before merging'
   - Check: 'Require code reviews before merging' (minimum: 1)
   - Check: 'Require code reviews' - Dismiss stale pull request approvals
   - Check: 'Include administrators' (optional)
   - Check: 'Restrict who can push to matching branches' (optional)

These rules ensure:
- All code is reviewed before merging
- Tests must pass
- Branch history is protected
- Only authorized users can merge
"

writeLines(protection_content, ".github/BRANCH_PROTECTION.md")
cat("✓ Created .github/BRANCH_PROTECTION.md\n")

# ============================================================================
# Step 4: Create development utilities
# ============================================================================
cat("\n=== Step 4: Creating GitHub Flow utilities ===\n")

# Create a helper script for common git operations
git_helpers <- "# GitHub Flow Helper Functions
# Source this file to use helper functions: source('R/git_helpers.R')

# Create and switch to a new feature branch
gh_feature <- function(feature_name) {
  if (!grepl('^[a-z0-9-]+$', feature_name)) {
    stop('Feature name must be lowercase with hyphens only')
  }
  
  system('git checkout main')
  system('git pull origin main')
  branch_name <- sprintf('feature/%s', feature_name)
  system(sprintf('git checkout -b %s', branch_name))
  cat(sprintf('✓ Created and switched to branch: %s\\n', branch_name))
}

# Create and switch to a new bugfix branch
gh_bugfix <- function(bug_name) {
  if (!grepl('^[a-z0-9-]+$', bug_name)) {
    stop('Bug name must be lowercase with hyphens only')
  }
  
  system('git checkout main')
  system('git pull origin main')
  branch_name <- sprintf('bugfix/%s', bug_name)
  system(sprintf('git checkout -b %s', branch_name))
  cat(sprintf('✓ Created and switched to branch: %s\\n', branch_name))
}

# Create and switch to a hotfix branch
gh_hotfix <- function(issue_name) {
  if (!grepl('^[a-z0-9-]+$', issue_name)) {
    stop('Issue name must be lowercase with hyphens only')
  }
  
  system('git checkout main')
  system('git pull origin main')
  branch_name <- sprintf('hotfix/%s', issue_name)
  system(sprintf('git checkout -b %s', branch_name))
  cat(sprintf('✓ Created and switched to branch: %s\\n', branch_name))
}

# Get current git status
gh_status <- function() {
  system('git status')
}

# Push current branch to origin
gh_push <- function(message = NULL) {
  current_branch <- system('git rev-parse --abbrev-ref HEAD', intern = TRUE)
  
  if (!is.null(message)) {
    system(sprintf('git add .'))
    system(sprintf('git commit -m \"%s\"', message))
  }
  
  system(sprintf('git push origin %s', current_branch))
  cat(sprintf('✓ Pushed to origin/%s\\n', current_branch))
}

# Switch back to main and pull latest
gh_main <- function() {
  system('git checkout main')
  system('git pull origin main')
  cat('✓ Switched to main and pulled latest changes\\n')
}

# List all branches
gh_branches <- function() {
  system('git branch -a')
}
"

writeLines(git_helpers, "R/git_helpers.R")
cat("✓ Created R/git_helpers.R with GitHub Flow helper functions\n")

# ============================================================================
# Step 5: Display summary and next steps
# ============================================================================
cat("\n========================================\n")
cat("     GitHub Flow Setup Complete\n")
cat("========================================\n")

cat("\n✓ Workflow documentation created (.github/WORKFLOW.md)\n")
cat("✓ Branch protection guide created (.github/BRANCH_PROTECTION.md)\n")
cat("✓ Git helper functions created (R/git_helpers.R)\n")

cat("\n=== Next Steps ===\n")
cat("1. Review the workflow documentation:\n")
cat("   - .github/WORKFLOW.md\n")
cat("   - .github/BRANCH_PROTECTION.md\n")
cat("\n2. (On GitHub) Set up branch protection:\n")
cat("   - Go to Settings > Branches\n")
cat("   - Create rule for 'main' branch\n")
cat("   - See .github/BRANCH_PROTECTION.md for details\n")
cat("\n3. Load helper functions for easier workflow:\n")
cat("   source('R/git_helpers.R')\n")
cat("   gh_feature('your-feature-name')  # Create feature branch\n")
cat("   gh_push('Commit message')         # Push changes\n")
cat("   gh_main()                         # Return to main\n")
cat("\n4. Create your first feature branch:\n")
cat("   git checkout -b feature/initial-setup\n")
cat("   # Make changes\n")
cat("   git push origin feature/initial-setup\n")
cat("   # Create PR on GitHub\n")
cat("\n========================================\n")
