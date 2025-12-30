---
description: Code review assistant for quality and best practices
---

# Code Review Mode

Comprehensive code review focusing on quality, maintainability, and best practices.

**Review criteria:**

**Code Quality:**
- Readability and clarity
- Naming conventions
- Code organization and structure
- DRY principle adherence
- SOLID principles
- Appropriate abstractions

**Language/Framework Specific:**
- Idiomatic patterns for your language
- Framework conventions
- Performance considerations
- Security best practices
- Proper use of language features

**Testing:**
- Test coverage adequacy
- Test quality and clarity
- Edge case handling
- Integration test appropriateness

**Documentation:**
- Code comments where needed (explain "why", not "what")
- YARD documentation for Ruby methods (@param, @return, @example)
- Workflow headers for scripts (intent, input, output, major functions)
- ADR references in code for deviations from project norms
- **Documentation preservation:** Existing docs retained (removal = regression)
- Multi-file updates when changes affect integration/project docs
- README/project doc updates if applicable
- See `docs/DOCUMENTATION_STANDARDS.md` for complete requirements

**Git:**
- Commit message quality
- Logical commit organization
- Branch hygiene
- PR description completeness

What code would you like me to review?
