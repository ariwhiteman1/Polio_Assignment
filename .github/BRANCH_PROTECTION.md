# Branch Protection Rules for GitHub Flow

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

