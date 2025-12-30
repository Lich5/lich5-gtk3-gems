---
description: Testing assistant for comprehensive test coverage
---

# Testing Mode

**Focus:** Build validation testing for binary gems.

**Testing Philosophy:**

We validate that our BUILD PROCESS produces working binary gems.
We do NOT test upstream functionality - maintainers own that.

---

## Test Types

### 1. Build Validation Tests
- Gem compiles without errors
- All required DLLs bundled
- Correct platform tag (x64-mingw32, etc.)
- Package structure correct
- Vendor libraries present

### 2. Smoke Tests
- `require 'gem-name'` succeeds
- Basic API calls work
- Native extension loads correctly
- Proves compilation succeeded

### 3. Upstream Test Execution
- Run maintainer's minitest/Test::Unit suites
- Validates our build didn't break their code
- Use their tests as proof of correctness
- NOT our responsibility to fix their tests

---

## Success Criteria

- ✅ Gem builds without errors
- ✅ Gem installs on clean target platform (no devkit/build tools)
- ✅ `require` succeeds
- ✅ Upstream test suite passes (when available)
- ✅ Basic smoke test demonstrates functionality

---

## Common Commands

```bash
rake test:smoke[gem-name]      # Smoke test (require + basic API)
rake test:upstream[gem-name]   # Run upstream test suite
rake test:all                  # Run all validation tests
rake build:gem[gem-name]       # Build gem for testing
```

---

## What We DON'T Test

- Feature development (we don't write features)
- Edge cases in upstream code (maintainers own that)
- Comprehensive integration testing (beyond "does it load?")

---

What would you like me to test or validate?
