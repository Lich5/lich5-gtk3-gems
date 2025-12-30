# Session Handoff Summary

**Date:** YYYY-MM-DD
**Session ID:** [session identifier if available]
**Token Usage:** X used / Y total (Z%)
**Reason for Handoff:** [50% checkpoint | 75% warning | 85% critical | 90% urgent | Token exhaustion | Natural break point]

---

## Work Completed This Session

### Commits Made

1. `abc1234` - type(scope): commit message
2. `def5678` - type(scope): commit message
3. `ghi9012` - type(scope): commit message

**Branch:** claude/branch-name-SESSION_ID
**Pushed to remote:** [Yes | No | Partial]

### Files Modified

- `file1.rb` - [Brief description of changes]
- `file2.md` - [Brief description of changes]
- `scripts/script.sh` - [Brief description of changes]

### Key Decisions Made

1. **Decision:** [What was decided]
   - **Rationale:** [Why this was chosen]
   - **Impact:** [What this affects]
   - **Documentation:** [ADR created? Where documented?]

2. **Decision:** [What was decided]
   - **Rationale:** [Why this was chosen]
   - **Impact:** [What this affects]

---

## Current State

**Branch:** claude/branch-name-SESSION_ID
**Work Unit:** `.claude/work-units/CURRENT.md`
**Status:** [In progress | Blocked | Ready for review | Complete]

**Last Action Completed:** [What was just finished]

**Next Action:** [What should happen next - be specific]

**Blockers:** [None | List any issues preventing progress]

---

## Context for Next Session

### Key Facts to Remember

- [Important context item 1]
- [Important context item 2]
- [Important context item 3]

### Gotchas / Things to Watch Out For

- [Warning or consideration 1]
- [Warning or consideration 2]

### Remaining Work

**From work unit:**
- [ ] Task 1 - [description]
- [ ] Task 2 - [description]
- [ ] Task 3 - [description]

**Additional items:**
- [ ] Item 1
- [ ] Item 2

**Estimated tokens needed for remaining work:** ~X tokens

---

## Quality Gates Status

- [ ] Build validation tests written and passing
- [ ] RuboCop clean (automation code)
- [ ] Gem builds successfully (if applicable)
- [ ] Documentation complete
- [ ] No modifications to `gems/` without ADR
- [ ] Zero regression verified
- [ ] Ready for commit/push/PR

---

## Handoff Instructions

**To resume work in new session:**

1. **Initialize framework:** Run `/init` command
2. **Review this summary:** Read entire handoff document
3. **Check git status:** Verify branch and uncommitted changes
4. **Review work unit:** Read `.claude/work-units/CURRENT.md`
5. **Review recent commits:** `git log -5` to see latest work
6. **Check token budget:** Start with fresh token allocation
7. **Resume from:** "Next Action" specified above

**Files to review before continuing:**
- [file1]
- [file2]
- [file3]

**Commands to run:**
```bash
git status
git log -5
# Any other setup commands
```

---

## Session Statistics

**Tools used:**
- Git operations: X
- File edits: Y
- File reads: Z

**Efficiency notes:**
- [Any observations about token usage patterns]
- [What worked well]
- [What to avoid next time]

---

**Template Version:** 1.0
**Created:** December 30, 2025
