# Development Workflow

## Philosophy

This project follows **test-before-develop** methodology with **quality gates at boundaries**.

All work must be:
- Spec-complete before validation
- Validated (tests + rubocop) before any push
- Documented according to project standards

---

## Branch Strategy

PRs are individual work-unit oriented, and stand alone.  If testing is done properly PRs should have 5 or less commits.

Examples:
- Git Flow (main, develop, feature/, hotfix/, release/)
- GitHub Flow (main, feature branches)
- Trunk-based development
- Custom strategy

**Key Principle:** [YOUR PRINCIPLE - e.g., "Always branch from develop", "Keep branches short-lived", etc.]

---

## Work Units

### CURRENT.md - The Active Work Unit

**Location:** `.claude/work-units/CURRENT.md`

**Purpose:**
- Single source of truth for "what I'm working on right now"
- Handoff protocol between planning and implementation
- Contains: specifications, acceptance criteria, context, constraints

### Archiving Work Units

**CRITICAL:** Archive completed work units before creating new ones.

**Why this matters:**
- Keeps CURRENT.md accurate (always shows active work)
- Prevents GitHub searches from surfacing stale/completed tasks
- Maintains clean project history

**How to archive:** [YOUR APPROACH - examples below]

**Examples:**
```bash
# Option 1: Date-based
mv .claude/work-units/CURRENT.md .claude/work-units/archive/2025-01-15-feature-name.md

# Option 2: Feature-based
mv .claude/work-units/CURRENT.md .claude/work-units/archive/feature-name/work-unit.md

# Option 3: Git-based (commit and delete, rely on git history)
git add .claude/work-units/CURRENT.md
git commit -m "chore: complete work unit for feature X"
rm .claude/work-units/CURRENT.md
```

**Choose the approach that fits your team's organization style.**

---

## Pre-Push Validation Checklist

**BEFORE EVERY PUSH:**

- [ ] Build validation tests written/updated for build changes
- [ ] Tests pass: `rake test:all` or gem-specific tests
- [ ] RuboCop clean: `rubocop` (automation code only: Rakefile, scripts/, test/)
- [ ] Gem builds successfully: `rake build:gem[gem-name]`
- [ ] No modifications to `gems/` unless authorized and documented in ADR
- [ ] Only necessary files included in commit
- [ ] Commit messages follow Conventional Commits (see below)
- [ ] YARD documentation complete for new Ruby code
- [ ] `git status` shows clean working tree (or only intended changes)

---

## Test Requirements

**Testing Philosophy:** This project validates binary gem builds, not upstream code functionality.

Tests are **ALWAYS** required for build changes:
- **Build Validation Tests** - Verify gem compiles, DLLs bundled, correct platform tag
- **Smoke Tests** - Verify `require 'gem-name'` succeeds and basic API works
- **Upstream Test Execution** - Run maintainer's test suite (if provided) to prove build correctness

**Success Criteria:**
- Gem builds without errors
- Gem installs on clean target platform (no devkit/build tools)
- `require` succeeds
- Upstream test suite passes (when available)
- Basic smoke test demonstrates functionality

### When Tests Can't Run in Isolation

Binary gem tests require target platform (e.g., Windows for x64-mingw32 gems). This is acceptable IF:
1. You've validated tests would pass on target platform (VM, CI/CD)
2. You've documented platform requirement
3. CI/CD will validate on actual platform

---

## Code Review & Quality Gates

Every change must pass:
1. **Build Validation** - `rake test:all` passing (or gem-specific tests)
2. **RuboCop** - Style compliance for automation code (Rakefile, scripts/, test/)
3. **Gem Build** - `rake build:gem[name]` succeeds
4. **Source Integrity** - No modifications to `gems/` without ADR documentation
5. **Logical validation** - Code follows project patterns from CLI_PRIMER and SOCIAL_CONTRACT

---

## Session Continuity

This document is your foundation. If you detect session compaction or context loss:
1. Re-read CLI_PRIMER (development philosophy)
2. Re-read SOCIAL_CONTRACT (team agreements)
3. Re-read this document (workflow procedures)
4. Reference them explicitly in decisions

**Signs of session loss:**
- Forgetting to include tests with code changes
- Skipping validation before pushing
- Not consulting known project documentation
- Forgetting to archive CURRENT.md before creating new work unit

---

## Common Patterns

### Creating a Feature Branch

```bash
# Customize for your branching strategy
git checkout -b feature/[name] [base-branch]
# Make changes
# Add tests
git add [files]
git commit -m "[your convention]"
# Validate (tests + linter)
git push -u origin feature/[name]
```

### Commit Message Format

```
[YOUR CONVENTION]
```

**Examples:**
```
# Customize these examples
feat: add user authentication
fix: resolve login timeout
chore: update dependencies

# Or if you use ticket numbers:
PROJ-123: implement user search
PROJ-124: fix pagination bug
```

---

## Mode-Specific Workflows

### Planning Mode (`/arch`)
1. Research existing architecture
2. Design approach
3. Create work unit in `.claude/work-units/CURRENT.md`
4. Define acceptance criteria
5. Hand off to implementation mode

### Investigation Mode (`/analyze`)
1. Reproduce issue or validate hypothesis
2. Experiment locally
3. Document findings
4. Either: create work unit for fix, or provide analysis

### Implementation Mode (`/code`)
1. Read work unit from CURRENT.md
2. Implement according to specifications
3. Write tests
4. Validate (tests + [YOUR CHECKS])
5. Commit and push
6. Archive CURRENT.md

---

## References

- **CLI_PRIMER** - Core development philosophy and testing strategy
- **SOCIAL_CONTRACT** - Team agreements and collaboration principles
- **SESSION_INIT_CHECKLIST** - Context recovery protocol

---

## Customization Notes

**This template should be adapted to your team's workflow.**

Update:
- Branch strategy section with your branching model
- Test requirements with your testing approach
- Pre-push checklist with your quality gates
- Commit format with your convention
- Archive approach with your preferred method

**The principles matter more than the specific format.**
