# GitHub Flow Helper Functions
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
  cat(sprintf('✓ Created and switched to branch: %s\n', branch_name))
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
  cat(sprintf('✓ Created and switched to branch: %s\n', branch_name))
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
  cat(sprintf('✓ Created and switched to branch: %s\n', branch_name))
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
    system(sprintf('git commit -m "%s"', message))
  }
  
  system(sprintf('git push origin %s', current_branch))
  cat(sprintf('✓ Pushed to origin/%s\n', current_branch))
}

# Switch back to main and pull latest
gh_main <- function() {
  system('git checkout main')
  system('git pull origin main')
  cat('✓ Switched to main and pulled latest changes\n')
}

# List all branches
gh_branches <- function() {
  system('git branch -a')
}

