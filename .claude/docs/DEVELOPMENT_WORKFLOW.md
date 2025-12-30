# Development Workflow

## Philosophy

This project follows **test-before-develop** methodology with **quality gates at boundaries**.

All work must be:
- Spec-complete before validation
- Validated (tests + rubocop) before any push
- Documented according to project standards

---

## Branch Strategy

**Model:** GitHub Flow (simplified)

**Main Branch:** `main` - Production-ready code

**Feature Branches:** `claude/descriptive-name-SESSION_ID`
- Session ID is required for push authentication
- Example: `claude/build-glib2-gem-1AEBM`
- Keep descriptive-name short and clear

**PR Requirements:**
- Individual work-unit oriented, stand alone
- 5 or less commits if testing is done properly
- Title follows convention: `feat(all):` or `fix(all):`

**Key Principles:**
- Always branch from `main`
- Keep branches short-lived (complete work unit, then merge)
- One work unit per branch/PR
- Validate before pushing (see Pre-Push Validation Checklist)

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
- Provides fast filesystem search + git history

**Hybrid Approach:** Date-based filesystem archive WITH git commit tracking

**Process:**

1. **Update CURRENT.md** with git commit history before archiving:
   ```markdown
   ## Git Commits (Parent → Final)

   **Parent Commit:** `abc1234` - feat(glib2): add build rake task
   - `def5678` - feat(glib2): add DLL extraction script
   - `ghi9012` - test(glib2): add smoke tests
   - `jkl3456` - docs(glib2): document build process
   **Final Commit:** `jkl3456`

   **PR:** #123 - feat(all): add glib2 binary gem build pipeline
   **PR Merge:** `mno7890` (merged to main)
   ```

2. **Archive to filesystem** with date-based naming:
   ```bash
   mv .claude/work-units/CURRENT.md \
      .claude/work-units/archive/2025-12-30-build-glib2-gem.md
   ```

3. **Commit the archive** to git:
   ```bash
   git add .claude/work-units/archive/2025-12-30-build-glib2-gem.md
   git commit -m "chore(all): archive work unit - build glib2 gem"
   git push
   ```

**Benefits:**
- **Fast Filesystem Search:** VSCode, Spotlight can search date-based archives
- **Git History:** `git log --all --grep="build-glib2-gem"` when needed
- **Traceability:** Work unit → Commits (embedded SHAs), Commits → Work unit
- **Both worlds:** Filesystem browsing AND git capabilities

---

## Pre-Push Validation Checklist

**BEFORE EVERY PUSH:**

- [ ] Build validation tests written/updated for build changes
- [ ] Tests pass: `rake test:all` or gem-specific tests
- [ ] RuboCop clean: `rubocop` (automation code only: Rakefile, scripts/, test/)
- [ ] Gem builds successfully: `rake build:gem[gem-name]`
- [ ] No modifications to `gems/` unless authorized and documented in ADR
- [ ] Documentation complete (see `docs/DOCUMENTATION_STANDARDS.md`):
  - YARD for Ruby methods (params, return, examples)
  - Workflow headers for scripts (intent, input, output, major functions)
  - Inline comments for "why" (not "what")
  - ADR references in code for deviations
  - Multi-file updates completed (integration/project docs)
  - Existing documentation preserved (removal = regression)
- [ ] Only necessary files included in commit
- [ ] Commit messages follow Conventional Commits (see below)
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
# Branch from main with session ID
git checkout main
git pull origin main
git checkout -b claude/build-glib2-gem-SESSION_ID

# Make changes
# Write/update build validation tests
git add [files]
git commit -m "feat(glib2): add smoke tests" # Scoped by gem

# Validate before push
rake test:all
rubocop
rake build:gem[glib2]  # if applicable

# Push to origin
git push -u origin claude/build-glib2-gem-SESSION_ID

# Create PR with title: feat(all): add glib2 binary gem build pipeline
```

### Commit Message Format

**Conventional Commits with gem-specific scope:**

```
<type>(<scope>): <description>

[optional body]
```

**Types:** feat, fix, docs, test, chore, refactor

**Scopes:** Gem name (glib2, gtk3, nokogiri, etc.) or `all` for cross-cutting changes

**Examples:**
```
feat(glib2): add smoke tests for glib2
fix(gtk3): correct DLL bundling paths
docs(nokogiri): document build process
test(glib2): add upstream test execution
chore(all): update .gitignore for gem artifacts
```

**PR Titles:** Use `feat(all):` or `fix(all):` to indicate project-wide scope

**Why:** Scoped commits enable filtering by gem (`git log --grep="(glib2)"`) and provide clear traceability

---

## PR and Commit Batching Strategy

**Philosophy:** Quality over frequency. Batch meaningful work. Keep PRs focused and reviewable.

### Commit Batching

**When to commit:**
✅ **Completed a logical unit of work** (feature, fix, refactor)
✅ **All tests passing** for the changes
✅ **Documentation updated** for the changes
✅ **Ready for independent review** (commit stands on its own)

❌ **Avoid:**
- After every single file edit
- "Checkpoint commits" without tests (use `git stash` instead)
- Work-in-progress without quality gates passing
- "Fix typo" commits (amend previous commit instead)

**Goal:** 3-5 well-crafted commits per PR, not 20+ micro-commits

### When to Push/Create PR

**Push to branch:**
- Work unit is complete
- All acceptance criteria met
- Quality gates passed (tests, RuboCop, documentation)
- OR: Approaching token limit (preserve work, see below)

**Create PR:**
- Work unit complete and pushed
- Ready for review
- PR title follows convention: `feat(all):` or `fix(all):`
- PR description includes context and testing notes

**Draft PRs:**
- Acceptable for work-in-progress if sharing for feedback
- Mark as draft until all quality gates pass
- Convert to ready-for-review when complete

### Token-Aware Commit Strategy

**If approaching token limit mid-work-unit:**

1. **Complete current logical change** (don't leave broken state)
2. **Run quality gates** (tests, RuboCop, build if applicable)
3. **Commit with proper message** (Conventional Commits)
4. **Push to preserve work** (branch is your backup)
5. **Create session handoff summary** (use template in `.claude/SESSION_HANDOFF_TEMPLATE.md`)
6. **PR can wait** - Create in next session when work unit complete
7. **OR: Create draft PR** - Mark as draft, complete in next session

**Example scenario:**
```
Token usage: ~85%
Work unit: 60% complete
Current change: Feature X implemented, tests passing

Actions:
1. Commit Feature X: "feat(glib2): add DLL extraction for glib2"
2. Push to branch
3. Create session handoff with remaining work
4. New session: Resume, complete work unit, finalize PR
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
