<!-- Copilot Custom Instructions for R GitHub Flow Project -->

This is an R project for managing the Ari Polio Assignment with GitHub Flow branching strategy.

## Project Context
- **Project Type**: R Project with Git/GitHub Integration
- **Main Purpose**: Polio Skills Assessment analysis with GitHub Flow workflow
- **Key Components**: 
  - R scripts for GitHub initialization and GitHub Flow setup
  - Git helper functions for easy workflow management
  - Documentation for branch protection and workflow

## Development Guidelines
- Use `source()` to load R scripts and helper functions
- Follow GitHub Flow: feature branches from main, PRs for merging
- Keep scripts organized in `R/` directory
- Store data in `data/`, outputs in `output/`
- Use semantic commit messages (start with verb)
- Load git helpers for easier commands: `source("R/git_helpers.R")`

## Key Files
- `R/01_github_init.R` - Repository initialization (run first)
- `R/02_github_flow_setup.R` - GitHub Flow documentation setup (run second)
- `R/git_helpers.R` - Helper functions for Git operations
- `.github/WORKFLOW.md` - GitHub Flow workflow documentation
- `.github/BRANCH_PROTECTION.md` - Branch protection configuration guide
- `README.md` - Project documentation

## Workflow Summary
1. Load helpers: `source("R/git_helpers.R")`
2. Create feature: `gh_feature("feature-name")`
3. Make changes to files
4. Commit and push: `gh_push("Descriptive message")`
5. Create Pull Request on GitHub
6. After review: merge on GitHub and `gh_main()`

## Quick Commands
- `gh_feature(name)` - Start new feature
- `gh_push(msg)` - Commit and push changes
- `gh_main()` - Switch to main branch
- `gh_status()` - View current status
- `gh_branches()` - List all branches

## Helpful R Packages
- `usethis` - R package development utilities
- `gert` - Git integration for R
- `devtools` - Development tools

## Next Actions
1. Update GitHub username in `R/01_github_init.R`
2. Run initialization script
3. Create repository on GitHub
4. Push code to GitHub
5. Configure branch protection in GitHub Settings
6. Begin development using GitHub Flow helpers
