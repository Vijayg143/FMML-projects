#!/bin/bash

# Git Push Helper Script
# This script helps resolve common git push rejection issues

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

A helper script to resolve git push rejection errors.

OPTIONS:
    -h, --help          Show this help message
    -b, --branch NAME   Specify branch name (default: current branch)
    -r, --rebase        Use rebase instead of merge
    -f, --force-with-lease   Force push with lease (use with caution)
    -y, --yes           Skip confirmation prompts

EXAMPLES:
    $0                  # Handle push rejection on current branch
    $0 -b main          # Handle push rejection on main branch
    $0 -r               # Use rebase strategy
    $0 -f               # Force push with lease

EOF
}

# Default values
BRANCH=""
USE_REBASE=false
FORCE_WITH_LEASE=false
AUTO_YES=false
STASHED=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -b|--branch)
            BRANCH="$2"
            shift 2
            ;;
        -r|--rebase)
            USE_REBASE=true
            shift
            ;;
        -f|--force-with-lease)
            FORCE_WITH_LEASE=true
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository. Please run this script from within a git repository."
    exit 1
fi

# Get current branch if not specified
if [ -z "$BRANCH" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Using current branch: $BRANCH"
else
    print_info "Using specified branch: $BRANCH"
    git checkout "$BRANCH" || {
        print_error "Failed to checkout branch: $BRANCH"
        exit 1
    }
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "You have uncommitted changes!"
    git status --short
    
    if [ "$AUTO_YES" = false ]; then
        read -p "Do you want to commit these changes first? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -p "Enter commit message: " commit_msg
            git add -A
            git commit -m "$commit_msg"
            print_success "Changes committed"
        else
            print_warning "Proceeding with uncommitted changes (they will be stashed)"
            git stash --include-untracked
            STASHED=true
        fi
    else
        print_warning "Auto-committing changes"
        git add -A
        git commit -m "Auto-commit: Uncommitted changes before sync"
        print_success "Changes committed"
    fi
fi

# Fetch latest changes
print_info "Fetching latest changes from remote..."
if ! git fetch origin "$BRANCH" 2>&1; then
    print_error "Failed to fetch from remote. Please check your network connection and authentication."
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        print_info "Restoring stashed changes..."
        git stash pop
    fi
    exit 1
fi

# Check if remote branch exists
if ! git rev-parse --verify "origin/$BRANCH" > /dev/null 2>&1; then
    print_warning "Remote branch origin/$BRANCH does not exist"
    print_info "Attempting to push and create remote branch..."
    if ! git push -u origin "$BRANCH"; then
        print_error "Failed to push new branch to remote"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            print_info "Restoring stashed changes..."
            git stash pop
        fi
        exit 1
    fi
    print_success "Branch pushed successfully!"
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        print_info "Restoring stashed changes..."
        git stash pop
        print_success "Stashed changes restored"
    fi
    exit 0
fi

# Check if local is behind remote
LOCAL=$(git rev-parse "$BRANCH")
REMOTE=$(git rev-parse "origin/$BRANCH")
BASE=$(git merge-base "$BRANCH" "origin/$BRANCH")

if [ "$LOCAL" = "$REMOTE" ]; then
    print_success "Your branch is up to date with origin/$BRANCH"
    print_info "Attempting to push..."
    if ! git push origin "$BRANCH"; then
        print_error "Failed to push to remote"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            print_info "Restoring stashed changes..."
            git stash pop
        fi
        exit 1
    fi
    print_success "Push successful!"
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        print_info "Restoring stashed changes..."
        git stash pop
        print_success "Stashed changes restored"
    fi
    exit 0
elif [ "$LOCAL" = "$BASE" ]; then
    print_info "Your branch is behind origin/$BRANCH"
    print_info "Fast-forwarding to latest changes..."
    if ! git merge --ff-only "origin/$BRANCH"; then
        print_error "Failed to fast-forward merge"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            print_info "Restoring stashed changes..."
            git stash pop
        fi
        exit 1
    fi
    print_success "Branch updated successfully!"
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        print_info "Restoring stashed changes..."
        git stash pop
        print_success "Stashed changes restored"
    fi
    exit 0
elif [ "$REMOTE" = "$BASE" ]; then
    print_info "Your branch is ahead of origin/$BRANCH"
    print_info "Pushing changes..."
    if ! git push origin "$BRANCH"; then
        print_error "Failed to push to remote"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            print_info "Restoring stashed changes..."
            git stash pop
        fi
        exit 1
    fi
    print_success "Push successful!"
    
    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
        print_info "Restoring stashed changes..."
        git stash pop
        print_success "Stashed changes restored"
    fi
    exit 0
else
    print_warning "Branches have diverged!"
    print_info "Local and remote branches have different commits"
    
    if [ "$FORCE_WITH_LEASE" = true ]; then
        print_warning "Force pushing with lease..."
        if [ "$AUTO_YES" = false ]; then
            read -p "Are you sure you want to force push? This may overwrite remote changes. (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_info "Aborting force push"
                
                # Restore stashed changes if any
                if [ "$STASHED" = true ]; then
                    print_info "Restoring stashed changes..."
                    git stash pop
                    print_success "Stashed changes restored"
                fi
                exit 1
            fi
        fi
        if ! git push --force-with-lease origin "$BRANCH"; then
            print_error "Failed to force push to remote"
            
            # Restore stashed changes if any
            if [ "$STASHED" = true ]; then
                print_info "Restoring stashed changes..."
                git stash pop
            fi
            exit 1
        fi
        print_success "Force push completed!"
        
        # Restore stashed changes if any
        if [ "$STASHED" = true ]; then
            print_info "Restoring stashed changes..."
            git stash pop
            print_success "Stashed changes restored"
        fi
        exit 0
    fi
    
    if [ "$USE_REBASE" = true ]; then
        print_info "Rebasing your changes on top of remote changes..."
        if git rebase "origin/$BRANCH"; then
            print_success "Rebase successful!"
            print_info "Pushing changes..."
            if ! git push origin "$BRANCH"; then
                print_error "Failed to push after rebase"
                
                # Restore stashed changes if any
                if [ "$STASHED" = true ]; then
                    print_info "Restoring stashed changes..."
                    git stash pop
                fi
                exit 1
            fi
            print_success "Push successful!"
            
            # Restore stashed changes if any
            if [ "$STASHED" = true ]; then
                print_info "Restoring stashed changes..."
                git stash pop
                print_success "Stashed changes restored"
            fi
        else
            print_error "Rebase failed with conflicts"
            print_info "Please resolve conflicts manually:"
            print_info "  1. Edit conflicting files"
            print_info "  2. git add <resolved-files>"
            print_info "  3. git rebase --continue"
            print_info "  4. git push origin $BRANCH"
            
            # Note: Don't restore stashed changes here - they should be restored
            # after conflicts are resolved and rebase is completed
            if [ "$STASHED" = true ]; then
                print_warning "You have stashed changes. Restore them with 'git stash pop' after resolving conflicts."
            fi
            exit 1
        fi
    else
        print_info "Merging remote changes into local branch..."
        if git merge "origin/$BRANCH" -m "Merge remote changes from origin/$BRANCH"; then
            print_success "Merge successful!"
            print_info "Pushing changes..."
            if ! git push origin "$BRANCH"; then
                print_error "Failed to push after merge"
                
                # Restore stashed changes if any
                if [ "$STASHED" = true ]; then
                    print_info "Restoring stashed changes..."
                    git stash pop
                fi
                exit 1
            fi
            print_success "Push successful!"
            
            # Restore stashed changes if any
            if [ "$STASHED" = true ]; then
                print_info "Restoring stashed changes..."
                git stash pop
                print_success "Stashed changes restored"
            fi
        else
            print_error "Merge failed with conflicts"
            print_info "Please resolve conflicts manually:"
            print_info "  1. Edit conflicting files (look for <<<<<<< markers)"
            print_info "  2. git add <resolved-files>"
            print_info "  3. git commit -m 'Resolve merge conflicts'"
            print_info "  4. git push origin $BRANCH"
            
            # Note: Don't restore stashed changes here - they should be restored
            # after conflicts are resolved and merge is completed
            if [ "$STASHED" = true ]; then
                print_warning "You have stashed changes. Restore them with 'git stash pop' after resolving conflicts."
            fi
            exit 1
        fi
    fi
fi
