#!/bin/bash
################################################################################
# SuperAI Platform - Manual Push Helper Script
################################################################################
# This script helps push the extracted superai-platform repository to GitHub
# from a machine with network access.
#
# Prerequisites:
# - Git installed
# - GitHub credentials configured (SSH key or personal access token)
# - Access to the extracted repository
#
# Usage:
#   ./push-superai-platform.sh [OPTIONS]
#
# Options:
#   --repo-path PATH       Path to extracted repository (default: current dir)
#   --use-ssh              Use SSH instead of HTTPS
#   --help                 Show this help message
################################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_PATH="${REPO_PATH:-.}"
REMOTE_URL="https://github.com/indestructiblemachinen/superai-platform.git"
USE_SSH=false

# Logging
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo-path)
            REPO_PATH="$2"
            shift 2
            ;;
        --use-ssh)
            USE_SSH=true
            REMOTE_URL="git@github.com:indestructiblemachinen/superai-platform.git"
            shift
            ;;
        --help)
            head -n 22 "$0" | tail -n +2 | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Banner
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     SuperAI Platform - Manual Push Helper                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Validate repository path
if [ ! -d "$REPO_PATH" ]; then
    log_error "Repository path does not exist: $REPO_PATH"
    exit 1
fi

if [ ! -d "$REPO_PATH/.git" ]; then
    log_error "Not a git repository: $REPO_PATH"
    exit 1
fi

cd "$REPO_PATH"
log_info "Working directory: $(pwd)"
echo ""

# Check Git identity
log_step "Step 1: Checking Git configuration"
if ! git config user.email &> /dev/null; then
    log_warn "Git user.email not configured"
    read -p "Enter your email: " email
    git config user.email "$email"
    log_info "Set user.email to: $email"
fi

if ! git config user.name &> /dev/null; then
    log_warn "Git user.name not configured"
    read -p "Enter your name: " name
    git config user.name "$name"
    log_info "Set user.name to: $name"
fi

log_info "Git identity: $(git config user.name) <$(git config user.email)>"
echo ""

# Check remote
log_step "Step 2: Configuring remote"
if git remote get-url origin &> /dev/null; then
    current_url=$(git remote get-url origin)
    log_warn "Remote 'origin' already exists: $current_url"
    read -p "Update to $REMOTE_URL? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin "$REMOTE_URL"
        log_info "Updated remote URL"
    fi
else
    git remote add origin "$REMOTE_URL"
    log_info "Added remote: $REMOTE_URL"
fi
echo ""

# Check branch
log_step "Step 3: Checking branch"
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
    log_warn "Current branch is '$current_branch', not 'main'"
    read -p "Rename to 'main'? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git branch -M main
        log_info "Renamed branch to 'main'"
    fi
fi
echo ""

# Show summary
log_step "Step 4: Repository Summary"
echo "Branch: $(git branch --show-current)"
echo "Commits: $(git log --oneline | wc -l)"
echo "Tags: $(git tag | wc -l)"
echo "Remote: $(git remote get-url origin)"
echo ""

git log --oneline --graph --decorate | head -10
echo ""

if git tag | grep -q .; then
    echo "Tags:"
    git tag
    echo ""
fi

# Confirm push
log_warn "Ready to push to GitHub!"
echo ""
echo "This will:"
echo "  1. Push all commits to: $REMOTE_URL"
echo "  2. Push all tags"
echo "  3. Set 'origin/main' as upstream"
echo ""
read -p "Continue with push? [y/N] " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Push cancelled by user"
    exit 0
fi

# Push
log_step "Step 5: Pushing to GitHub"
echo ""

log_info "Pushing commits..."
if git push -u origin main; then
    log_info "✅ Commits pushed successfully"
else
    log_error "Failed to push commits"
    echo ""
    echo "Troubleshooting:"
    echo "  - Check your network connection"
    echo "  - Verify GitHub credentials are configured"
    echo "  - For HTTPS: Use personal access token"
    echo "  - For SSH: Check SSH key is added to GitHub"
    exit 1
fi
echo ""

log_info "Pushing tags..."
if git push --tags; then
    log_info "✅ Tags pushed successfully"
else
    log_warn "Failed to push tags (commits were pushed)"
fi
echo ""

# Success
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  Push Complete! 🎉                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Repository is now available at:"
echo "  https://github.com/indestructiblemachinen/superai-platform"
echo ""
log_info "Next steps:"
echo "  1. Visit the repository on GitHub"
echo "  2. Verify all files and commits are present"
echo "  3. Check that GitHub Actions workflows are running"
echo "  4. Review and merge any pull requests if needed"
echo ""
log_info "To clone the new repository:"
echo "  git clone https://github.com/indestructiblemachinen/superai-platform.git"
echo ""

exit 0
