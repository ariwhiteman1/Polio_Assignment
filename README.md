# Ari_Polio_Assignment - GitHub Flow Development

A comprehensive R project setup for managing the Polio Skills Assessment with GitHub Flow branching strategy.

## Project Structure

```
Ari_Polio_Assignment/
├── R/                          # R scripts directory
│   ├── 01_github_init.R       # GitHub repository initialization
│   ├── 02_github_flow_setup.R # GitHub Flow workflow setup
│   ├── git_helpers.R          # Helper functions for Git operations
│   └── [your analysis scripts]
├── data/                       # Data files directory
│   └── [input data files]
├── output/                     # Output directory
│   └── [generated results]
├── .github/                    # GitHub configuration
│   ├── WORKFLOW.md            # GitHub Flow workflow documentation
│   └── BRANCH_PROTECTION.md   # Branch protection setup guide
├── .gitignore                  # Git ignore rules
└── README.md                   # This file
```

## Quick Start

### 1. Initialize GitHub Repository

```r
# In R console, run:
source("R/01_github_init.R")
```

This script will:
- Initialize a local git repository
- Create a `.gitignore` file
- Make an initial commit
- Configure the GitHub remote

**Important**: Update `github_username` and `repo_name` in the script before running.

### 2. Create Repository on GitHub

1. Go to [https://github.com/new](https://github.com/new)
2. Create repository named: `Ari_Polio_Assignment`
3. **Important**: Do NOT initialize with README, .gitignore, or license
4. Copy the repository URL

### 3. Setup GitHub Flow Workflow

```r
# In R console, run:
source("R/02_github_flow_setup.R")
```

This will create documentation and helper functions for GitHub Flow.

### 4. Push to GitHub

```bash
# In terminal/PowerShell:
git branch -M main
git push -u origin main
```

### 5. Load Helper Functions

```r
# In R console, run:
source("R/git_helpers.R")
```

Now you can use convenient functions for Git operations.

## GitHub Flow Workflow

### Creating a Feature

```r
# Load helper functions
source("R/git_helpers.R")

# Create feature branch
gh_feature("descriptive-feature-name")

# Work on your feature
# ...edit files...

# Commit and push
gh_push("Add description of changes")
```

### Submit for Review

1. Go to GitHub repository
2. You should see a prompt to "Create Pull Request"
3. Click "Compare & pull request"
4. Add description of your changes
5. Request reviewers
6. Create PR

### After Approval

1. Merge the PR on GitHub
2. Delete the feature branch
3. Back to main branch:

```r
gh_main()  # Switches to main and pulls latest
```

## Helper Functions

Load with: `source("R/git_helpers.R")`

| Function | Purpose |
|----------|---------|
| `gh_feature(name)` | Create feature branch |
| `gh_bugfix(name)` | Create bugfix branch |
| `gh_hotfix(name)` | Create hotfix branch (urgent fixes) |
| `gh_push(message)` | Commit and push changes |
| `gh_main()` | Switch to main and pull latest |
| `gh_status()` | Show git status |
| `gh_branches()` | List all branches |
| `gh_pull()` | Pull latest from current branch |
| `gh_log(n)` | Show last n commits |
| `gh_current()` | Show current branch |

## Setting Up Branch Protection (GitHub Settings)

To protect the `main` branch from accidental changes:

1. Go to **Settings** > **Branches**
2. Click **Add rule**
3. Branch name pattern: `main`
4. Check these options:
   - ✓ Require a pull request before merging
   - ✓ Require status checks to pass before merging
   - ✓ Require code reviews before merging (minimum 1)
   - ✓ Dismiss stale pull request approvals

See `.github/BRANCH_PROTECTION.md` for detailed instructions.

## Typical Workflow Example

```r
# 1. Create feature
source("R/git_helpers.R")
gh_feature("add-data-analysis")

# 2. Do work - edit analysis script
# Edit: R/analysis.R

# 3. Commit and push
gh_push("Add data analysis and visualization")

# 4. On GitHub: Create Pull Request, get review

# 5. After approval, merge on GitHub

# 6. Back to main
gh_main()
```

## Commit Message Guidelines

- Start with a verb: Add, Fix, Update, Remove, Refactor
- First line: max 50 characters
- Reference issues: "Fixes #123"

Example:
```
Add polio case data analysis

- Calculate incidence rates
- Generate visualization
- Add summary statistics

Fixes #15
```

## Documentation Files

- `.github/WORKFLOW.md` - Detailed GitHub Flow workflow
- `.github/BRANCH_PROTECTION.md` - Branch protection setup
- `R/01_github_init.R` - Initialization script with detailed comments
- `R/02_github_flow_setup.R` - GitHub Flow configuration and utilities

## R Project Structure Tips

- Put all R scripts in `R/` directory
- Keep raw data in `data/`
- Save outputs to `output/`
- Use `source()` to load helper functions and utilities
- Create numbered scripts for sequential analysis: `01_data_import.R`, `02_analysis.R`, etc.

## Useful Git Commands

```bash
# See current branch
git branch

# See all branches (including remote)
git branch -a

# See recent commits
git log --oneline -10

# See what's changed
git status

# See specific changes
git diff

# Undo last commit (keep changes)
git reset --soft HEAD~1

# View remote
git remote -v
```

## Troubleshooting

**Q: How do I switch branches?**
```r
system('git checkout branch-name')
# Or using helper:
gh_main()  # To go back to main
```

**Q: How do I see what changed?**
```r
gh_status()  # See changed files
system('git diff')  # See specific changes
```

**Q: How do I undo the last commit?**
```bash
git reset --soft HEAD~1
```

**Q: I made a mistake on main branch!**
```r
# Quick recovery:
system('git reset --hard origin/main')
```

## Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Desktop](https://desktop.github.com/) - Visual Git client alternative
- [R Project](https://www.r-project.org/) - Official R website

## Next Steps

1. ✓ Initialize local repository
2. ✓ Create GitHub repository
3. ✓ Setup GitHub Flow
4. → Configure branch protection on GitHub
5. → Create your first feature branch
6. → Start development!

---

**Last Updated**: November 2025  
**Author**: Ari (GitHub Flow Setup)
