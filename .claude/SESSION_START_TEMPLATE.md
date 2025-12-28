# Session Start Template

Copy this template when starting a new Claude session on this project.

---

## Context for Claude

I'm working on the **Lich5 GTK3 Binary Gems** project.

**Project goal:** Build precompiled binary gems for GTK3 with bundled libraries for Lich5 distribution.

**Current status:** [UPDATE THIS]
- Phase: Initial Setup / Windows POC / Full Build / etc.
- Last completed: [what was done last]
- Next task: [what to work on]

**Repository:** https://github.com/Lich5/lich5-gtk3-gems

**Please read:**
1. `.claude/PROJECT_CONTEXT.md` - Full project context
2. Current phase docs in `docs/`

**Today I need help with:** [SPECIFIC TASK]

---

## Example Session Starts

### Example 1: Building First Gem

```
I'm working on the Lich5 GTK3 Binary Gems project.

Current status:
- Phase: Windows POC
- Scaffolding complete
- Need to import glib2 source and build first binary gem

Please read .claude/PROJECT_CONTEXT.md for full context.

Today I need help with:
Importing glib2 source from ruby-gnome and creating a binary gemspec for Windows (x64-mingw32).
```

### Example 2: CI/CD Setup

```
I'm working on the Lich5 GTK3 Binary Gems project.

Current status:
- Phase: Full Windows Stack
- Can build gems locally
- Need to automate in GitHub Actions

Please read .claude/PROJECT_CONTEXT.md for full context.

Today I need help with:
Debugging the GitHub Actions workflow for Windows gem builds. The MSYS2 setup is failing.
```

### Example 3: Adding New Gem

```
I'm working on the Lich5 GTK3 Binary Gems project.

Current status:
- Phase: Expand Gem Scope
- GTK3 stack complete
- Adding sqlite3 binary gem

Please read .claude/PROJECT_CONTEXT.md for full context.

Today I need help with:
Adding sqlite3 to the build system and creating a Windows binary gem.
```

---

## Quick Commands

**Check status:**
```bash
rake status
```

**Build a gem:**
```bash
rake build:gem[glib2]
```

**Test:**
```bash
rake test:quick
```

**List all tasks:**
```bash
rake -T
```
