# Git Troubleshooting Guide

This guide helps you resolve common Git issues you might encounter when working with this repository.

## Error: Push Rejected - Remote Contains Work You Don't Have Locally

### Problem
When you try to push your changes, you see an error like:

```
$ git push origin main
To https://github.com/Vijayg143/FMML-projects.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'https://github.com/Vijayg143/FMML-projects.git'
hint: Updates were rejected because the remote contains work that you do not
hint: have locally. This is usually caused by another repository pushing to
hint: the same ref. If you want to integrate the remote changes, use
hint: 'git pull' before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

### Why This Happens
This error occurs when:
- Someone else has pushed changes to the remote repository
- You haven't pulled those changes to your local repository yet
- Git prevents you from pushing to avoid overwriting the remote changes

### Solution

#### Method 1: Pull and Merge (Recommended)
This is the safest approach as it preserves both your changes and the remote changes.

```bash
# Step 1: Pull the remote changes
git pull origin main

# Step 2: If there are no conflicts, the merge will complete automatically
# Step 3: Push your changes
git push origin main
```

#### Method 2: Pull with Rebase (For a Cleaner History)
This applies your changes on top of the remote changes.

```bash
# Step 1: Pull with rebase
git pull --rebase origin main

# Step 2: If there are conflicts, resolve them and continue
# git add <resolved-files>
# git rebase --continue

# Step 3: Push your changes
git push origin main
```

#### Method 3: Force Push (Use with Extreme Caution)
⚠️ **WARNING**: Only use this if you're absolutely sure you want to overwrite the remote changes.

```bash
# This will overwrite remote changes - use only if you're certain!
git push --force origin main
```

### Handling Merge Conflicts

If you encounter merge conflicts during `git pull`:

1. **Identify conflicted files**:
   ```bash
   git status
   ```

2. **Open the conflicted files** and look for conflict markers:
   ```
   <<<<<<< HEAD
   Your changes
   =======
   Remote changes
   >>>>>>> branch-name
   ```

3. **Resolve conflicts** by editing the files to keep the desired changes

4. **Mark as resolved**:
   ```bash
   git add <resolved-file>
   ```

5. **Complete the merge**:
   ```bash
   git commit
   ```

6. **Push your changes**:
   ```bash
   git push origin main
   ```

### Prevention Tips

1. **Pull before you start working**:
   ```bash
   git pull origin main
   ```

2. **Pull regularly** while working on long tasks

3. **Use feature branches** instead of working directly on main:
   ```bash
   git checkout -b my-feature-branch
   # Make your changes
   git push origin my-feature-branch
   ```

4. **Communicate with team members** about major changes

## Other Common Git Issues

### Issue: Accidentally Committed to Wrong Branch

**Solution**:
```bash
# Save your changes
git stash

# Switch to the correct branch
git checkout correct-branch

# Apply your changes
git stash pop

# Commit and push
git add .
git commit -m "Your message"
git push origin correct-branch
```

### Issue: Need to Undo Last Commit (Not Pushed Yet)

**Solution**:
```bash
# Keep changes but undo commit
git reset --soft HEAD~1

# Discard changes and undo commit
git reset --hard HEAD~1
```

### Issue: Large Files Causing Push to Fail

**Solution**:
```bash
# Option 1: Use git-filter-repo (recommended)
# Install: pip install git-filter-repo
git filter-repo --path path/to/large/file --invert-paths

# Option 2: Use git lfs for large files
git lfs track "*.ipynb"
git add .gitattributes
git commit -m "Add git lfs tracking"
```

## Getting Help

If you're still stuck:
1. Check the [Git documentation](https://git-scm.com/doc)
2. Use `git --help` or `git <command> --help`
3. Search for your error message online
4. Ask for help from your team or instructor

## Best Practices

1. **Commit often** with meaningful messages
2. **Pull before you push** to avoid conflicts
3. **Don't commit sensitive data** (passwords, API keys, etc.)
4. **Use .gitignore** to exclude unnecessary files
5. **Review your changes** before committing: `git diff`
6. **Test your code** before pushing

---

For more information about Git, visit: https://git-scm.com/
