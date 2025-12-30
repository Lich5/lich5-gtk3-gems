#!/bin/bash
# Session Start Hook for lich5-gtk3-gems
#
# Purpose: Basic environment checks and expectation setting for Web Claude
# Scope: Lightweight validation, not full development environment setup

set -e

echo "🔧 Lich5 GTK3 Binary Gems - Session Start"
echo ""

# Ruby version check
echo "📍 Checking Ruby environment..."
if command -v ruby >/dev/null 2>&1; then
  RUBY_VERSION=$(ruby --version)
  echo "   Ruby: $RUBY_VERSION"

  if ! echo "$RUBY_VERSION" | grep -q "3.3"; then
    echo "   ⚠️  Expected Ruby 3.3.x (see .ruby-version)"
  else
    echo "   ✅ Ruby version matches project requirements"
  fi
else
  echo "   ⚠️  Ruby not found in environment"
fi

echo ""

# RuboCop availability check
echo "📍 Checking linting tools..."
if command -v rubocop >/dev/null 2>&1; then
  echo "   ✅ RuboCop available for linting automation code"
else
  echo "   ⚠️  RuboCop not available (optional for Web Claude)"
fi

echo ""

# Platform limitations reminder
echo "📋 Platform Context:"
echo "   • Primary target: Windows x64-mingw32 binary gems"
echo "   • GTK3 source: MSYS2 (Windows-specific)"
echo "   • Build validation: GitHub Actions (Windows runner)"
echo ""
echo "🌐 Web Claude Capabilities:"
echo "   ✅ Write build automation (Rake tasks, scripts)"
echo "   ✅ Write tests (smoke tests, build validation)"
echo "   ✅ Update documentation"
echo "   ✅ Architecture planning and work unit creation"
echo "   ✅ Code review and RuboCop validation"
echo ""
echo "   ⚠️  Cannot build Windows binary gems (requires Windows + MSYS2)"
echo "   ⚠️  Cannot test gem installation on Windows"
echo "   ⚠️  Build validation requires GitHub Actions or CLI Claude"
echo ""

# Current project phase
if [ -f ".claude/PROJECT_CONTEXT.md" ]; then
  PHASE=$(grep "Current Focus:" .claude/PROJECT_CONTEXT.md | cut -d: -f2 | xargs)
  if [ -n "$PHASE" ]; then
    echo "📌 Current Phase: $PHASE"
    echo ""
  fi
fi

# Work unit check
if [ -f ".claude/work-units/CURRENT.md" ]; then
  echo "📄 Active work unit detected: .claude/work-units/CURRENT.md"
  WORK_UNIT_TITLE=$(grep "^# Work Unit:" .claude/work-units/CURRENT.md | head -1 | sed 's/# Work Unit: //')
  if [ -n "$WORK_UNIT_TITLE" ]; then
    echo "   → $WORK_UNIT_TITLE"
  fi
  echo ""
fi

echo "✅ Session initialized. Ready for work."
echo ""
echo "💡 Tip: Use /init to load full Claude Framework documentation"
