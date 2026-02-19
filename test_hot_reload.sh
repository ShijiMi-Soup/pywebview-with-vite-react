#!/bin/bash
set -euo pipefail

# Test script for hot reload functionality
# This script verifies that the dev mode implementation is working correctly

echo "🧪 Testing Hot Reload Implementation..."
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track test results
PASSED=0
FAILED=0

# Test 1: Check if backend/index.py has dev mode support
echo "Test 1: Checking if backend/index.py supports dev mode..."
if grep -q "if '--dev' in sys.argv or os.environ.get('PYWEBVIEW_DEV')" backend/index.py; then
    echo -e "${GREEN}✓ PASSED${NC} - Dev mode detection found in backend/index.py"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} - Dev mode detection not found in backend/index.py"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 2: Check if backend returns correct URL in dev mode
echo "Test 2: Checking if backend returns localhost:5173 in dev mode..."
if grep -q "return 'http://localhost:5173'" backend/index.py; then
    echo -e "${GREEN}✓ PASSED${NC} - Correct dev server URL found"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} - Dev server URL not configured correctly"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 3: Check if package.json has dev:backend script
echo "Test 3: Checking if package.json has dev:backend script..."
if grep -q '"dev:backend"' package.json; then
    echo -e "${GREEN}✓ PASSED${NC} - dev:backend script found in package.json"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} - dev:backend script not found in package.json"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 4: Check if .gitignore excludes Python cache
echo "Test 4: Checking if .gitignore excludes Python cache files..."
if grep -q "__pycache__" .gitignore && grep -q "*.pyc" .gitignore; then
    echo -e "${GREEN}✓ PASSED${NC} - Python cache files in .gitignore"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} - Python cache files not properly ignored"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 5: Check if README has dev mode documentation
echo "Test 5: Checking if README.md documents the new dev mode..."
if grep -q "Hot Module Replacement" README.md || grep -q "hot reload" README.md; then
    echo -e "${GREEN}✓ PASSED${NC} - README.md documents hot reload feature"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC} - README.md might need hot reload documentation"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 5.5: Check if window.loaded check is present
echo "Test 5.5: Checking if backend has window.loaded check..."
if grep -q "if window.loaded:" backend/index.py; then
    echo -e "${GREEN}✓ PASSED${NC} - Window loaded check found in backend/index.py"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAILED${NC} - Window loaded check not found (race condition fix missing)"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test 6: Check if venv exists (optional - for local testing)
echo "Test 6: Checking if Python virtual environment exists (optional)..."
if [ -d "venv" ]; then
    echo -e "${GREEN}✓ PASSED${NC} - Virtual environment found"
    PASSED=$((PASSED + 1))
    
    # Test 7: If venv exists, test the actual function
    echo ""
    echo "Test 7: Testing get_entrypoint() function..."
    
    if [ -f "venv/bin/python" ] || [ -f "venv/Scripts/python.exe" ]; then
        # Create test script
        cat > /tmp/test_hot_reload.py << 'EOF'
import sys
import os

# Set up path
repo_root = os.getcwd()
sys.path.insert(0, os.path.join(repo_root, 'backend'))

# Test dev mode
sys.argv = ['test', '--dev']
os.chdir(os.path.join(repo_root, 'backend'))

from index import get_entrypoint
entry = get_entrypoint()
if entry == 'http://localhost:5173':
    print("✓ Dev mode working")
    sys.exit(0)
else:
    print(f"✗ Dev mode failed: got {entry}")
    sys.exit(1)
EOF
        
        if [ -f "venv/bin/python" ]; then
            PYTHON_CMD="./venv/bin/python"
        else
            PYTHON_CMD="./venv/Scripts/python.exe"
        fi
        
        if $PYTHON_CMD /tmp/test_hot_reload.py 2>/dev/null; then
            echo -e "${GREEN}✓ PASSED${NC} - get_entrypoint() works correctly in dev mode"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAILED${NC} - get_entrypoint() not working correctly"
            FAILED=$((FAILED + 1))
        fi
    fi
else
    echo -e "${YELLOW}⊘ SKIPPED${NC} - Virtual environment not found (run 'python -m venv venv' and install requirements)"
fi
echo ""

# Summary
echo "========================================"
echo "Test Summary:"
echo "========================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo ""
    echo "Hot reload implementation is working correctly!"
    echo ""
    echo "To use hot reload in development:"
    echo "  Terminal 1: npm run dev"
    echo "  Terminal 2: npm run dev:backend"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "Please check the implementation and try again."
    exit 1
fi
