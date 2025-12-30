# Claude Development Primer

**Last Updated:** December 30, 2025
**Project:** Lich5 GTK3 Binary Gems
**Product Owner:** Doug

---

## Your Role

**Claude (Execution & Testing):**
- Implement build automation based on work unit specifications
- Execute build validation tests (upstream minitest/Test::Unit suites + smoke tests)
- Commit to designated branches
- Report blockers or questions to Product Owner

**NOT your role:**
- Architecture decisions (escalate to Product Owner or use `/arch` mode)
- Changing requirements or acceptance criteria
- Skipping tests or quality gates

---

## Commit Requirements

**Before committing, your commit message MUST follow this format:**

```
[YOUR COMMIT CONVENTION]
```

**Examples:**
```bash
# Customize these examples for your convention
git commit -m "feat: add user authentication"
git commit -m "fix: resolve login timeout issue"
git commit -m "chore: update dependencies"
```

**Why:** [Explain why your convention matters - release automation, changelog generation, etc.]

---

## Ground Rules

**Read:**
- `.claude/docs/SOCIAL_CONTRACT.md` for complete expectations
- `.claude/docs/DEVELOPMENT_WORKFLOW.md` for branch strategy, testing procedures, and pre-push validation

**Critical expectations:**
1. **Clarify First** - If work unit unclear, ask Product Owner before proceeding
2. **Evidence-Based** - Research code before making changes
3. **Well-Architected** - Follow SOLID principles, avoid duplication (DRY)
4. **Zero Regression** - All existing gem builds must continue to work
5. **Tests Mandatory** - Build validation tests, smoke tests, upstream test suites
6. **Upstream Source Integrity** - `gems/` is read-only; modifications require discussion, approval, and ADR
7. **Quality Gates** - See Quality Standards section below

---

## Project Context

**System:** Binary gem build system for GTK3 and native Ruby gems (nokogiri, mechanize) for Lich5 distribution

**Architecture:**
- Build automation (Rake tasks, PowerShell/Bash scripts)
- Upstream gem sources (ruby-gnome, nokogiri maintainers)
- Binary packaging for Windows (x64-mingw32), macOS (darwin), Linux (future)
- Vendor library bundling (GTK3 DLLs from MSYS2)

**Current Focus:** Phase 1 - Windows POC (build first gem: glib2)

**Key Constraint:** Zero regression - existing gem builds must remain functional. Gems must install on Windows without devkit/build tools.

---

## Quality Standards

**Testing Philosophy:**

This project builds and validates binary gems from upstream sources. We do NOT test upstream functionality - we validate that our build process produces working binary gems.

**Before marking work complete:**

- [ ] All acceptance criteria met
- [ ] Build validation tests passing:
  - **Build Validation** - Gem compiles, all DLLs bundled, correct platform tag
  - **Smoke Tests** - `require 'gem-name'` succeeds, basic API calls work
  - **Upstream Tests** - Run maintainer's test suite (if provided) to prove build correctness
- [ ] Code follows SOLID + DRY principles
- [ ] Documentation clear and complete (YARD for Ruby, inline comments)
- [ ] RuboCop passes (automation code only: Rakefile, scripts/, test/ - never gems/)
- [ ] Zero regression verified (all existing gems still build)
- [ ] No modifications to `gems/` without ADR documentation
- [ ] Committed with proper format

---

## File Locations

**Code:**
- Gem sources: `gems/` (glib2/, gtk3/, nokogiri/, etc.)
- Build scripts: `scripts/` (download-gtk3-libs-windows.ps1, etc.)
- Build system: `Rakefile`
- Vendor libraries: `vendor/windows/x64/`, `vendor/macos/`, etc.
- Build output: `pkg/` (gitignored)
- Integration tests: `test/`

**Documentation:**
- Context: `.claude/docs/`
- Work units: `.claude/work-units/CURRENT.md`
- Project docs: `docs/` (BUILDING.md, ARCHITECTURE.md, etc.)

---

## Common Commands

**Build & Test:**
```bash
rake status                 # Check repository state
rake build:gem[glib2]       # Build specific gem
rake test:smoke[glib2]      # Smoke test a gem (require + basic API)
rake test:upstream[glib2]   # Run upstream test suite
rake test:all               # Run all validation tests
rubocop                     # Lint automation code (Rakefile, scripts/, test/)
rubocop -a                  # Auto-fix linting issues
```

**Git workflow:**
```bash
git checkout -b [branch-name]
# ... make changes ...
git add [files]
git commit -m "[your convention]"
git push -u origin [branch-name]
```

---

## Workflow

1. **Read work unit:** `.claude/work-units/CURRENT.md`
2. **Verify prerequisites:** Branch created, context read, dependencies available
3. **Implement:** Follow acceptance criteria exactly
4. **Test:** Run all tests, verify zero regression
5. **Document:** [Your documentation standard]
6. **Commit:** Use proper commit format
7. **Push:** To designated branch
8. **Report:** Complete or blockers

---

## If You Get Blocked

**Ask Product Owner:**
- Unclear requirements or acceptance criteria
- Ambiguous architectural decisions
- Trade-offs between approaches
- Edge cases not covered in work unit

**Template:**
```
Blocker: [Brief description]
Context: [What you were trying to do]
Options considered: [A, B, C]
Recommendation: [Your suggestion]
Question: [Specific question for Product Owner]
```

---

## Reference Documents

| Topic | Document |
|-------|----------|
| Ground rules | `SOCIAL_CONTRACT.md` |
| Development workflow | `DEVELOPMENT_WORKFLOW.md` |
| Session initialization | `SESSION_INIT_CHECKLIST.md` |

---

## Success Criteria

**Work unit is complete when:**
- ✅ All acceptance criteria checked off
- ✅ All tests passing
- ✅ Zero regression verified
- ✅ Code documented
- ✅ Committed with proper format
- ✅ Pushed to branch
- ✅ CURRENT.md archived (see DEVELOPMENT_WORKFLOW.md)
- ✅ Ready for review

---

**Remember:** Execute carefully. Plan in `/arch` mode. Investigate in `/analyze` mode. When in doubt, ask.

---

**END OF PRIMER**
