# GitHub Repository Initialization Script
# This script initializes a local git repository and connects it to a GitHub remote
# Usage: source("R/01_github_init.R")

# Set CRAN mirror if not already set
if (is.null(getOption("repos"))) {
  options(repos = c(CRAN = "https://cran.r-project.org/"))
}

# Install necessary packages if not already installed
required_packages <- c("usethis", "gert")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    tryCatch({
      install.packages(pkg, repos = "https://cran.r-project.org/")
      library(pkg, character.only = TRUE)
    }, error = function(e) {
      cat(sprintf("Warning: Could not install %s, continuing without it\n", pkg))
    })
  }
}

# Configuration
github_username <- "ariwhiteman1"  # Replace with your GitHub username
repo_name <- "Polio_Assignment"
repo_description <- "Polio SIR Skills Assessment - GitHub Flow Development"
is_private <- FALSE  # Set to TRUE if you want a private repository

# ============================================================================
# Step 1: Initialize local git repository
# ============================================================================
cat("\n=== Step 1: Initializing local git repository ===\n")

# Check if git is already initialized
if (!dir.exists(".git")) {
  system("git init")
  cat("✓ Git repository initialized\n")
} else {
  cat("✓ Git repository already exists\n")
}

# Configure git user (if not already configured)
current_user <- system("git config --global user.name", intern = TRUE)
current_email <- system("git config --global user.email", intern = TRUE)

if (length(current_user) == 0 || current_user == "") {
  cat("\n! Git user not configured. Please set your git user:\n")
  cat("  Run: git config --global user.name 'Your Name'\n")
  cat("  Run: git config --global user.email 'your.email@example.com'\n")
} else {
  cat(sprintf("✓ Git configured as: %s (%s)\n", current_user, current_email))
}

# ============================================================================
# Step 2: Create initial commit
# ============================================================================
cat("\n=== Step 2: Creating initial commit ===\n")

# Create .gitignore if it doesn't exist
if (!file.exists(".gitignore")) {
  gitignore_content <- ".Rhistory
.RData
.Rproj.user/
.DS_Store
*.Rproj
output/*
!output/.gitkeep
.env
.vscode/
node_modules/
"
  writeLines(gitignore_content, ".gitignore")
  cat("✓ Created .gitignore\n")
}

# Create initial commit
system("git add .")
status_output <- system("git status --porcelain", intern = TRUE)

if (length(status_output) > 0) {
  system("git commit -m 'Initial commit: Project setup'")
  cat("✓ Initial commit created\n")
} else {
  cat("✓ No changes to commit\n")
}

# ============================================================================
# Step 3: Add GitHub remote
# ============================================================================
cat("\n=== Step 3: Adding GitHub remote ===\n")

# Check if remote already exists
remote_exists <- system("git remote get-url origin", intern = TRUE, ignore.stderr = TRUE)

if (length(remote_exists) == 0 || grepl("fatal", remote_exists[1])) {
  remote_url <- sprintf("https://github.com/%s/%s.git", github_username, repo_name)
  cat(sprintf("Remote URL: %s\n", remote_url))
  
  system(sprintf("git remote add origin %s", remote_url))
  cat("✓ GitHub remote added (not verified - run 'git remote -v' to verify)\n")
  cat("\nTo complete setup:\n")
  cat("1. Create the repository on GitHub: https://github.com/new\n")
  cat(sprintf("   - Repository name: %s\n", repo_name))
  cat(sprintf("   - Description: %s\n", repo_description))
  cat(sprintf("   - Private: %s\n", if (is_private) "Yes" else "No"))
  cat("2. Run: git branch -M main\n")
  cat("3. Run: git push -u origin main\n")
} else {
  cat(sprintf("✓ Remote already exists: %s\n", remote_exists))
}

# ============================================================================
# Step 4: Display summary
# ============================================================================
cat("\n=== Setup Summary ===\n")
cat("✓ Local repository initialized\n")
cat(sprintf("✓ Repository name: %s\n", repo_name))
cat(sprintf("✓ GitHub username: %s\n", github_username))
cat("\nNext steps:\n")
cat("1. Update github_username in this script with your actual username\n")
cat("2. Create the repository on GitHub\n")
cat("3. Push the initial commit: git push -u origin main\n")
cat("4. Run: source('R/02_github_flow_setup.R') to set up GitHub Flow\n")
