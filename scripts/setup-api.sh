#!/bin/bash

# Setup script for Nuge API Python environment
# This ensures all required tools are available for Husky hooks

echo "🐍 Setting up Nuge API Python environment..."
echo ""

# Check if we're in the right directory
if [ ! -f "api/pyproject.toml" ]; then
  echo "❌ Please run this script from the root of the Nuge project"
  exit 1
fi

# Navigate to API directory
cd api

echo "📦 Installing Python dependencies with uv..."
if ! command -v uv >/dev/null 2>&1; then
  echo "❌ uv is not installed. Please install it first:"
  echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
  exit 1
fi

# Install dependencies
uv sync

if [ $? -ne 0 ]; then
  echo "❌ Failed to install dependencies"
  exit 1
fi

echo ""
echo "🔧 Verifying tool availability..."

# Check if tools are available
tools=("black" "isort" "ruff" "mypy")
missing_tools=()

for tool in "${tools[@]}"; do
  if [ -f "venv/bin/$tool" ] || [ -f ".venv/bin/$tool" ] || command -v "$tool" >/dev/null 2>&1; then
    echo "✅ $tool is available"
  else
    echo "❌ $tool is not available"
    missing_tools+=("$tool")
  fi
done

if [ ${#missing_tools[@]} -eq 0 ]; then
  echo ""
  echo "🎉 API environment is ready!"
  echo "✅ All Python tools are available for Husky hooks"
  echo ""
  echo "💡 Next steps:"
  echo "   1. Try making a commit to test the hooks"
  echo "   2. The pre-commit hook will format Python files automatically"
  echo "   3. The pre-push hook will run comprehensive checks"
else
  echo ""
  echo "⚠️ Some tools are missing: ${missing_tools[*]}"
  echo "🔧 Try running: uv add --dev ${missing_tools[*]}"
fi

cd ..
echo ""
echo "✅ Setup complete!" 