# Git Workflow Guide

## Common Issue: Push Rejection Due to Remote Changes

### Problem
When you try to push your local changes to a remote repository, you might encounter this error:

```
! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/username/repository.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
```

### Why This Happens
This error occurs when:
- Someone else pushed commits to the remote branch after you last pulled
- You're working on a different machine and made changes there
- The remote repository was modified directly (e.g., through GitHub web interface)

### Solution

#### Option 1: Pull and Merge (Recommended for most cases)
```bash
# Fetch the latest changes from remote
git pull origin main

# Resolve any merge conflicts if they occur
# Edit conflicting files, then:
git add <conflicted-files>
git commit -m "Resolve merge conflicts"

# Push your changes
git push origin main
```

#### Option 2: Pull with Rebase (For cleaner history)
```bash
# Fetch and rebase your changes on top of remote changes
git pull --rebase origin main

# If conflicts occur, resolve them and:
git add <conflicted-files>
git rebase --continue

# Push your changes
git push origin main
```

#### Option 3: Force Push (⚠️ Use with extreme caution)
**WARNING:** This will overwrite remote changes. Only use if you're absolutely sure you want to discard remote changes.

```bash
# This will overwrite remote history
git push --force origin main

# Safer alternative that won't overwrite if remote has new commits
git push --force-with-lease origin main
```

### Best Practices

1. **Pull before you start working**
   ```bash
   git pull origin main
   ```

2. **Commit and push frequently**
   - Make small, logical commits
   - Push your changes regularly to avoid large conflicts

3. **Check status before pushing**
   ```bash
   git status
   git log origin/main..HEAD  # See commits you're about to push
   ```

4. **Communicate with your team**
   - Let team members know when you're working on shared files
   - Use feature branches for new features

### Working with Feature Branches

Instead of pushing directly to main, use feature branches:

```bash
# Create and switch to a new branch
git checkout -b feature/my-feature

# Make your changes and commit
git add .
git commit -m "Add new feature"

# Push your feature branch
git push origin feature/my-feature

# Create a pull request on GitHub
# After review, merge through GitHub interface
```

### Handling Merge Conflicts

When conflicts occur during pull:

1. **Identify conflicting files**
   ```bash
   git status
   ```

2. **Open conflicting files**
   Look for conflict markers:
   ```
   <<<<<<< HEAD
   Your changes
   =======
   Remote changes
   >>>>>>> branch-name
   ```

3. **Resolve conflicts**
   - Edit the file to keep the desired changes
   - Remove conflict markers

4. **Mark as resolved**
   ```bash
   git add <resolved-file>
   ```

5. **Complete the merge**
   ```bash
   git commit -m "Resolve merge conflicts"
   ```

### Useful Git Commands

```bash
# Check current branch and status
git status

# See commit history
git log --oneline -10

# See what will be pushed
git diff origin/main..HEAD

# See remote branches
git branch -r

# Fetch without merging
git fetch origin

# See differences with remote
git diff origin/main

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) ⚠️
git reset --hard HEAD~1
```

### Getting Help

```bash
# Get help for any git command
git help <command>
git <command> --help

# Examples:
git help pull
git help push
```
