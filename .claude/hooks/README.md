# Claude Hooks

This directory contains hooks that execute during Claude Code sessions.

## session-start.sh

**Purpose:** Basic environment checks and expectation setting for Web Claude.

**When it runs:** Automatically at the start of each Claude Code session.

**What it does:**
1. ✅ Checks Ruby version (expects 3.3.x)
2. ✅ Checks RuboCop availability
3. ✅ Reminds about platform limitations (Windows binary gem builds)
4. ✅ Shows current project phase
5. ✅ Detects active work units

**What it does NOT do:**
- ❌ Install dependencies
- ❌ Set up build environment
- ❌ Attempt to build gems
- ❌ Fail if checks don't pass

**Philosophy:** Lightweight and informational, not prescriptive.

---

## Design Decisions

**Why minimal?**

This project builds Windows binary gems that require:
- Windows platform (x64-mingw32)
- MSYS2 for GTK3 libraries
- Actual gem builds happen on GitHub Actions or CLI Claude

Web Claude's role is primarily:
- Writing build automation scripts
- Planning architecture
- Creating documentation
- Code review

**A heavy session-start hook would:**
- Attempt to set up an environment Web Claude can't use
- Create false expectations
- Add complexity without benefit

**This minimal hook:**
- Sets correct expectations
- Provides basic sanity checks
- Stays out of the way
- Reminds about platform constraints

---

## For CLI Claude

CLI Claude (running on user's local filesystem) has access to:
- Full Ruby environment
- Rake tasks
- RuboCop
- Local gem building (for testing)
- Git operations

The session-start hook works for CLI Claude too, but CLI Claude has the full toolchain already configured by the user.

---

## Customization

To add more checks, edit `session-start.sh` and add them after the existing checks. Keep it lightweight and informational.
