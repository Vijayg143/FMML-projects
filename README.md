# FMML-projects
Submissions of FMML

## Git Workflow Help

If you encounter Git push rejection errors (like "failed to push some refs"), we've provided helpful resources:

### Quick Fix
Use our automated helper script:
```bash
./git-push-helper.sh
```

The script will:
- Automatically detect and resolve push rejections
- Fetch and merge/rebase remote changes
- Handle conflicts gracefully
- Push your changes successfully

### Options
```bash
./git-push-helper.sh -h              # Show help
./git-push-helper.sh -b main         # Work on specific branch
./git-push-helper.sh -r              # Use rebase instead of merge
./git-push-helper.sh -f              # Force push with lease (careful!)
```

### Manual Resolution
See [GIT_WORKFLOW_GUIDE.md](GIT_WORKFLOW_GUIDE.md) for detailed instructions on:
- Understanding push rejection errors
- Manual resolution steps
- Best practices for Git workflows
- Handling merge conflicts

## Repository Contents
This repository contains Jupyter notebooks for the Foundations of Modern Machine Learning (FMML) course, organized by modules:
- Module 1-9: Lab exercises and projects
- Basic Python tutorials
- Project submissions
