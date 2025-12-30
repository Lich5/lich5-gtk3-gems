---
description: Switch to implementation mode for coding and testing
model: claude-haiku-4-5-20251001
---

# Implementation Mode

**Switching to implementation mode with Haiku for efficient execution.**

Focus on:
- Executing work units from `.claude/work-units/CURRENT.md`
- Writing clean, efficient code
- Following established patterns in the codebase
- Writing comprehensive tests (unit, integration, regression)
- Running full validation (tests + style checks)
- Committing with proper conventions
- Pushing to designated branches

**Full toolkit available** - efficient execution mode.

**Quality checklist before pushing:**
- [ ] All acceptance criteria met
- [ ] Build validation tests written and passing
- [ ] RuboCop clean (automation code only: Rakefile, scripts/, test/)
- [ ] Gem builds successfully (if applicable)
- [ ] Documentation complete (see `docs/DOCUMENTATION_STANDARDS.md`):
  - YARD for Ruby methods (params, return, examples)
  - Workflow headers for scripts (intent, input, output, major functions)
  - Inline comments explain "why" (not "what")
  - ADR references in code for deviations from project norms
  - Existing documentation preserved (removal = regression)
- [ ] No modifications to `gems/` without ADR documentation
- [ ] Zero regression verified (all existing gem builds still work)
- [ ] Committed with proper format (Conventional Commits with gem scopes)
- [ ] Ready for review

**Remember:** Mark work unit complete and archive before starting new work.

---

Ready to implement. What would you like me to build or fix?
