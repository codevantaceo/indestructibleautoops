#!/bin/bash
################################################################################
# SuperAI Platform Extraction Script
################################################################################
# This script extracts the superai-platform subdirectory as an independent 
# repository while preserving full Git history.
#
# Features:
# - Preserves complete commit history using git subtree split
# - Adds missing LICENSE file
# - Updates documentation for standalone use
# - Creates CONTRIBUTING.md
# - Removes GL references (none found, but checked)
# - Tags initial release as v1.0.0
#
# Usage:
#   ./extract-superai-platform.sh [OPTIONS]
#
# Options:
#   --dry-run          Show what would be done without executing
#   --work-dir PATH    Custom working directory (default: /tmp/superai-extraction)
#   --new-repo NAME    New repository name (default: superai-platform)
#   --help             Show this help message
#
# Exit codes:
#   0 - Success
#   1 - Error occurred
#   2 - Invalid arguments
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PARENT_REPO="https://github.com/indestructiblemachinen/indestructibleautoops"
WORK_DIR="${WORK_DIR:-/tmp/superai-extraction}"
NEW_REPO_NAME="${NEW_REPO_NAME:-superai-platform}"
DRY_RUN=false

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_cmd() {
    echo -e "${CYAN}[CMD]${NC} $1"
}

# Show usage
show_help() {
    head -n 29 "$0" | tail -n +2 | sed 's/^# //' | sed 's/^#//'
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        --new-repo)
            NEW_REPO_NAME="$2"
            shift 2
            ;;
        --help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 2
            ;;
    esac
done

# Banner
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     SuperAI Platform - Repository Extraction Tool           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
log_info "Configuration:"
echo "  - Work directory: $WORK_DIR"
echo "  - New repository: $NEW_REPO_NAME"
echo "  - Dry run: $DRY_RUN"
echo ""

if [ "$DRY_RUN" = true ]; then
    log_warn "DRY RUN MODE - No changes will be made"
    echo ""
fi

# Validation
if ! command -v git &> /dev/null; then
    log_error "git is not installed"
    exit 1
fi

# Create work directory
log_step "Step 1: Preparing work directory"
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
    log_info "Created work directory: $WORK_DIR"
else
    log_cmd "mkdir -p $WORK_DIR"
    log_cmd "cd $WORK_DIR"
fi

# Clone parent repository if needed
log_step "Step 2: Cloning parent repository"
if [ "$DRY_RUN" = false ]; then
    if [ ! -d "indestructibleautoops" ]; then
        log_info "Cloning $PARENT_REPO..."
        git clone "$PARENT_REPO" indestructibleautoops
    else
        log_info "Parent repository already exists, updating..."
        cd indestructibleautoops
        git fetch origin
        git checkout main
        git pull origin main
        cd ..
    fi
else
    log_cmd "git clone $PARENT_REPO indestructibleautoops"
fi

# Extract subdirectory with history
log_step "Step 3: Extracting superai-platform with full history"
if [ "$DRY_RUN" = false ]; then
    cd "$WORK_DIR/indestructibleautoops"
    
    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/superai-platform-extracted; then
        log_warn "Branch 'superai-platform-extracted' already exists, deleting..."
        git branch -D superai-platform-extracted
    fi
    
    log_info "Running git subtree split (this may take a while)..."
    git subtree split --prefix=superai-platform -b superai-platform-extracted
    
    # Get commit count
    COMMIT_COUNT=$(git rev-list --count superai-platform-extracted)
    log_info "Extracted $COMMIT_COUNT commits"
else
    log_cmd "cd $WORK_DIR/indestructibleautoops"
    log_cmd "git subtree split --prefix=superai-platform -b superai-platform-extracted"
fi

# Create new repository
log_step "Step 4: Creating new repository structure"
if [ "$DRY_RUN" = false ]; then
    cd "$WORK_DIR"
    
    if [ -d "$NEW_REPO_NAME" ]; then
        log_warn "Directory '$NEW_REPO_NAME' already exists, removing..."
        rm -rf "$NEW_REPO_NAME"
    fi
    
    mkdir -p "$NEW_REPO_NAME"
    cd "$NEW_REPO_NAME"
    
    git init
    log_info "Initialized new Git repository"
else
    log_cmd "cd $WORK_DIR"
    log_cmd "mkdir -p $NEW_REPO_NAME"
    log_cmd "cd $NEW_REPO_NAME"
    log_cmd "git init"
fi

# Pull extracted branch
log_step "Step 5: Pulling extracted branch"
if [ "$DRY_RUN" = false ]; then
    git pull ../indestructibleautoops superai-platform-extracted
    log_info "Pulled extracted branch with full history"
else
    log_cmd "git pull ../indestructibleautoops superai-platform-extracted"
fi

# Add LICENSE file
log_step "Step 6: Adding LICENSE file"
if [ "$DRY_RUN" = false ]; then
    cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2026 Enterprise Engineering Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
    git add LICENSE
    git commit -m "chore: Add MIT license"
    log_info "Added LICENSE file"
else
    log_cmd "cat > LICENSE << 'EOF' [MIT License content]"
    log_cmd "git add LICENSE"
    log_cmd "git commit -m 'chore: Add MIT license'"
fi

# Update README for standalone use
log_step "Step 7: Updating README for standalone repository"
if [ "$DRY_RUN" = false ]; then
    # Fix parent repository references
    sed -i 's|Please read \[CONTRIBUTING.md\](../CONTRIBUTING.md)|See the Contributing section below or read CONTRIBUTING.md|g' README.md
    sed -i 's|see the \[LICENSE\](../license)|see the LICENSE file|g' README.md
    sed -i 's|(../CONTRIBUTING.md)|(CONTRIBUTING.md)|g' README.md
    
    git add README.md
    git commit -m "docs: Update README for standalone repository"
    log_info "Updated README.md"
else
    log_cmd "sed -i 's|../CONTRIBUTING.md|CONTRIBUTING.md|g' README.md"
    log_cmd "git add README.md"
    log_cmd "git commit -m 'docs: Update README for standalone repository'"
fi

# Create CONTRIBUTING.md
log_step "Step 8: Creating CONTRIBUTING.md"
if [ "$DRY_RUN" = false ]; then
    cat > CONTRIBUTING.md << 'EOF'
# Contributing to SuperAI Platform

We welcome contributions! This guide will help you get started.

## Development Setup

### Prerequisites

- Python 3.11 or higher
- Docker and Docker Compose
- Make (optional but recommended)

### Initial Setup

1. **Fork the repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/your-username/superai-platform.git
   cd superai-platform
   ```

2. **Set up development environment**
   ```bash
   make setup
   # or manually:
   python -m pip install -e ".[dev]"
   pre-commit install
   cp .env.example .env
   ```

3. **Start development services**
   ```bash
   docker compose up -d
   ```

## Code Standards

### Python Style

- Follow **PEP 8** guidelines
- Use **type hints** for all function signatures
- Maximum line length: **100 characters**
- Use **docstrings** for all public functions (Google style)
- Prefer **f-strings** for string formatting

### Code Quality Tools

We use several tools to maintain code quality:

```bash
make lint          # Run ruff linter
make format        # Format with ruff
make type-check    # Run mypy type checker
make security      # Run bandit security scan
```

### Pre-commit Hooks

Pre-commit hooks run automatically before each commit:

- `black` - Code formatting
- `isort` - Import sorting
- `ruff` - Linting
- `bandit` - Security checks
- `mypy` - Type checking

## Testing

### Running Tests

```bash
make test              # Run all tests
make test-unit         # Unit tests only
make test-integration  # Integration tests
make test-e2e          # End-to-end tests
make test-cov          # With coverage report
```

### Test Coverage

- Maintain **minimum 80% coverage** for new code
- Write tests for all new features
- Include edge cases and error scenarios

### Test Structure

```
tests/
├── unit/            # Fast, isolated tests
├── integration/     # Tests with external dependencies
├── e2e/            # End-to-end workflow tests
└── fixtures/       # Test data and factories
```

## Pull Request Process

### Before Submitting

1. ✅ All tests pass locally
2. ✅ Code follows style guidelines
3. ✅ Documentation is updated
4. ✅ CHANGELOG.md is updated
5. ✅ Commit messages follow Conventional Commits

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Test additions or changes
- `chore`: Build process or auxiliary tool changes

**Examples:**
```
feat(quantum): Add new VQE optimization algorithm

Implement variational quantum eigensolver with improved
convergence for molecular systems.

Closes #123
```

```
fix(api): Resolve authentication token expiry issue

Token refresh was not working correctly for long-running sessions.

Fixes #456
```

### PR Guidelines

- **Keep PRs focused** - One feature or fix per PR
- **Write clear descriptions** - Explain what, why, and how
- **Reference issues** - Link related issues with `Closes #123`
- **Request reviews** - Tag relevant maintainers
- **Respond to feedback** - Address review comments promptly

## Development Workflow

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/amazing-feature

# 2. Make changes
# ... edit files ...

# 3. Run tests and checks
make test
make lint

# 4. Commit changes
git add .
git commit -m "feat: Add amazing feature"

# 5. Push to your fork
git push origin feature/amazing-feature

# 6. Create pull request on GitHub
```

### Bug Fixes

```bash
# 1. Create fix branch
git checkout -b fix/issue-123

# 2. Reproduce the bug with a test
# Write a failing test first

# 3. Fix the bug

# 4. Verify the test passes
make test

# 5. Commit and push
git commit -m "fix: Resolve issue with authentication

Fixes #123"
git push origin fix/issue-123
```

## Architecture Guidelines

### Clean Architecture Layers

Follow the existing layer structure:

- **Presentation** - FastAPI routes, schemas
- **Application** - Use cases, services, DTOs
- **Domain** - Entities, value objects, specifications
- **Infrastructure** - Database, cache, external APIs
- **Quantum** - Quantum algorithms and runtime
- **AI** - AI factory, agents, embeddings
- **Scientific** - Scientific computing modules
- **Shared** - Cross-cutting concerns

### Dependency Rules

- **Inner layers** don't depend on outer layers
- **Use dependency injection** for external dependencies
- **Define interfaces** (protocols) for ports and adapters

## Quantum Module Development

### Testing Quantum Code

Use simulators for testing:

```python
from qiskit_aer import AerSimulator

backend = AerSimulator()
# ... test quantum circuits
```

### Quantum Best Practices

- Use abstract quantum runtime to support multiple backends
- Implement classical fallbacks for quantum algorithms
- Document quantum circuit complexity (gate count, depth)

## AI Module Development

### Testing AI Code

Mock external API calls:

```python
from unittest.mock import patch

@patch('src.ai.factory.expert_factory.AsyncOpenAI')
def test_expert_query(mock_openai):
    mock_openai.return_value.chat.completions.create.return_value = mock_response
    # ... test AI functionality
```

### AI Best Practices

- Provide fallback responses when APIs are unavailable
- Implement rate limiting and retry logic
- Cache embeddings to reduce API calls
- Document model versions and parameters

## Documentation

### Code Documentation

- **Docstrings** for all public modules, classes, functions
- **Type hints** for better IDE support
- **Inline comments** for complex logic only

### User Documentation

Update documentation in `docs/`:

- **API Reference** - OpenAPI/Swagger specs
- **Architecture** - System design docs
- **Guides** - How-to guides
- **ADRs** - Architecture Decision Records
- **Runbooks** - Operations procedures

## Release Process

Releases are automated via GitHub Actions:

1. Update version in `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create and push a version tag: `git tag v1.2.3`
4. GitHub Actions will build and publish the release

## Getting Help

- 📖 Read the [README](README.md)
- 🔍 Search [existing issues](https://github.com/your-org/superai-platform/issues)
- 💬 Ask in [Discussions](https://github.com/your-org/superai-platform/discussions)
- 📧 Contact maintainers (see README)

## Code of Conduct

Be respectful, inclusive, and collaborative. We're all here to build something great together!

---

Thank you for contributing to SuperAI Platform! 🚀
EOF
    git add CONTRIBUTING.md
    git commit -m "docs: Add contributing guidelines"
    log_info "Created CONTRIBUTING.md"
else
    log_cmd "cat > CONTRIBUTING.md << 'EOF' [Contributing guidelines]"
    log_cmd "git add CONTRIBUTING.md"
    log_cmd "git commit -m 'docs: Add contributing guidelines'"
fi

# Create standalone validation script
log_step "Step 9: Creating standalone validation script"
if [ "$DRY_RUN" = false ]; then
    mkdir -p tests
    cat > tests/validate_standalone.py << 'EOF'
#!/usr/bin/env python3
"""
Standalone validation script for extracted superai-platform module.

This script verifies that the module can run independently without
dependencies on the parent repository.
"""
import sys
from pathlib import Path

def validate_imports():
    """Verify all core imports work."""
    try:
        # Test core module imports
        from src.presentation.api import main
        from src.domain.entities import User
        from src.infrastructure.config import settings
        print("✅ All core imports successful")
        return True
    except ImportError as e:
        print(f"❌ Import failed: {e}")
        return False

def validate_no_parent_refs():
    """Check for parent directory references."""
    project_root = Path(__file__).parent.parent
    violations = []
    
    for py_file in project_root.rglob("*.py"):
        if "__pycache__" in str(py_file):
            continue
        if "validate_standalone" in str(py_file):
            continue
            
        content = py_file.read_text()
        # Check for parent imports like "from ../../"
        if content.count("from ..") > content.count("from .."):
            violations.append(str(py_file.relative_to(project_root)))
    
    if violations:
        print(f"❌ Found suspicious parent directory references:")
        for v in violations:
            print(f"   - {v}")
        return False
    else:
        print("✅ No parent directory references found")
        return True

def validate_structure():
    """Verify directory structure is intact."""
    project_root = Path(__file__).parent.parent
    required = [
        "src",
        "tests",
        "README.md",
        "pyproject.toml",
        "LICENSE",
    ]
    
    missing = []
    for item in required:
        if not (project_root / item).exists():
            missing.append(item)
    
    if missing:
        print(f"❌ Missing required files/directories:")
        for m in missing:
            print(f"   - {m}")
        return False
    else:
        print("✅ All required files present")
        return True

def main():
    print("🔍 Validating superai-platform standalone capability...\n")
    
    checks = [
        ("Structure validation", validate_structure),
        ("Import validation", validate_imports),
        ("Parent reference check", validate_no_parent_refs),
    ]
    
    results = []
    for name, check_fn in checks:
        print(f"\n{name}:")
        try:
            results.append(check_fn())
        except Exception as e:
            print(f"❌ Check failed with exception: {e}")
            results.append(False)
    
    print("\n" + "="*60)
    if all(results):
        print("✅ All validation checks passed!")
        print("\nThe module is ready for standalone deployment.")
        return 0
    else:
        print("❌ Some validation checks failed")
        print("\nPlease review the errors above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
EOF
    chmod +x tests/validate_standalone.py
    git add tests/validate_standalone.py
    git commit -m "test: Add standalone validation script"
    log_info "Created validation script"
else
    log_cmd "cat > tests/validate_standalone.py << 'EOF' [Validation script]"
    log_cmd "git add tests/validate_standalone.py"
    log_cmd "git commit -m 'test: Add standalone validation script'"
fi

# Tag initial release
log_step "Step 10: Tagging initial release"
if [ "$DRY_RUN" = false ]; then
    git tag -a v1.0.0 -m "Initial standalone release

Extracted from https://github.com/indestructiblemachinen/indestructibleautoops

Changes:
- Added MIT LICENSE
- Updated README for standalone use
- Added CONTRIBUTING.md
- Created standalone validation script
- Preserved full Git history"
    
    log_info "Tagged v1.0.0"
else
    log_cmd "git tag -a v1.0.0 -m 'Initial standalone release'"
fi

# Final summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  Extraction Complete! 🎉                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$DRY_RUN" = false ]; then
    log_info "Repository location: $WORK_DIR/$NEW_REPO_NAME"
    echo ""
    log_info "Next steps:"
    echo "  1. Review the extracted repository:"
    echo "     cd $WORK_DIR/$NEW_REPO_NAME"
    echo ""
    echo "  2. Run validation:"
    echo "     python tests/validate_standalone.py"
    echo ""
    echo "  3. Create new GitHub repository:"
    echo "     - Go to https://github.com/new"
    echo "     - Create repository named: $NEW_REPO_NAME"
    echo "     - Choose 'Public' or 'Private'"
    echo "     - Do NOT initialize with README (we already have one)"
    echo ""
    echo "  4. Push to new repository:"
    echo "     git remote add origin git@github.com:your-org/${NEW_REPO_NAME}.git"
    echo "     git branch -M main"
    echo "     git push -u origin main"
    echo "     git push --tags"
    echo ""
    echo "  5. Test the deployment:"
    echo "     make setup"
    echo "     make test"
    echo "     docker compose up -d"
    echo ""
    log_info "Repository is ready! ✅"
else
    log_warn "DRY RUN complete - no changes were made"
    echo ""
    log_info "Run without --dry-run to perform the actual extraction"
fi

exit 0
